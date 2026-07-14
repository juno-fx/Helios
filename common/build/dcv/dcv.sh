#!/bin/bash
# Master Amazon DCV installer — dispatches to distro-specific installer
# reference: https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html

set -e

echo "Amazon DCV Installer"

case "$SRC" in
    jammy|noble)
        bash /tmp/debian-dcv.sh
        ;;
    rocky-9|alma-9)
        bash /tmp/rhel-dcv.sh
        ;;
    *)
        echo "DCV not supported on $SRC, skipping"
        exit 0
        ;;
esac

# Build the abstract-socket namespace shim used by the password-authenticated
# direct-connect endpoint (svc-dcv-direct). Two dcvserver instances in one
# container collide on DCV's fixed abstract unix socket names
# (@/com/nicesoftware/dcv/*); this LD_PRELOAD shim appends ${DCV_SOCKET_SUFFIX}
# to those names so a second instance (and its agents) get a private set.
# Source lives here (not a separate .c) so no Dockerfile COPY change is needed.
echo "Building DCV socket-namespace shim..."
cat >/tmp/dcv-socket-ns.c <<'SHIM_EOF'
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>

#define DCV_ABSTRACT_PREFIX "/com/nicesoftware/dcv/"

typedef int (*sockcall_t)(int, const struct sockaddr *, socklen_t);

static int rewrite_addr(const struct sockaddr *addr, socklen_t len,
                        struct sockaddr_un *out, socklen_t *outlen)
{
	const char *sfx = getenv("DCV_SOCKET_SUFFIX");
	const struct sockaddr_un *un = (const struct sockaddr_un *)addr;
	size_t off = offsetof(struct sockaddr_un, sun_path);
	size_t namelen, sfxlen, plen = strlen(DCV_ABSTRACT_PREFIX);

	if (!sfx || !*sfx || !addr || len <= off + 1)
		return 0;
	if (un->sun_family != AF_UNIX || un->sun_path[0] != '\0')
		return 0; /* not an abstract unix socket */
	namelen = len - off; /* includes leading NUL of the abstract name */
	if (namelen - 1 < plen || memcmp(un->sun_path + 1, DCV_ABSTRACT_PREFIX, plen) != 0)
		return 0; /* not a DCV socket */
	sfxlen = strlen(sfx);
	if (off + namelen + sfxlen > sizeof(struct sockaddr_un))
		return 0; /* would not fit, leave untouched */

	memcpy(out, un, len);
	memcpy((char *)out->sun_path + namelen, sfx, sfxlen);
	*outlen = (socklen_t)(len + sfxlen);
	return 1;
}

int bind(int fd, const struct sockaddr *addr, socklen_t len)
{
	static sockcall_t real_bind;
	struct sockaddr_un rw;
	socklen_t rwlen;

	if (!real_bind)
		real_bind = (sockcall_t)dlsym(RTLD_NEXT, "bind");
	if (rewrite_addr(addr, len, &rw, &rwlen))
		return real_bind(fd, (struct sockaddr *)&rw, rwlen);
	return real_bind(fd, addr, len);
}

int connect(int fd, const struct sockaddr *addr, socklen_t len)
{
	static sockcall_t real_connect;
	struct sockaddr_un rw;
	socklen_t rwlen;

	if (!real_connect)
		real_connect = (sockcall_t)dlsym(RTLD_NEXT, "connect");
	if (rewrite_addr(addr, len, &rw, &rwlen))
		return real_connect(fd, (struct sockaddr *)&rw, rwlen);
	return real_connect(fd, addr, len);
}
SHIM_EOF

if command -v apt >/dev/null 2>&1; then
    apt update && apt install --no-install-recommends -y gcc libc6-dev
    gcc -shared -fPIC -O2 -o /usr/lib/dcv-socket-ns.so /tmp/dcv-socket-ns.c -ldl
    apt purge -y gcc libc6-dev && apt autoremove -y
    apt clean -y && rm -rf /var/lib/apt/lists/*
else
    dnf install -y gcc glibc-devel
    gcc -shared -fPIC -O2 -o /usr/lib/dcv-socket-ns.so /tmp/dcv-socket-ns.c -ldl
    dnf remove -y gcc glibc-devel && dnf clean all
fi
rm -f /tmp/dcv-socket-ns.c
echo "DCV socket-namespace shim installed at /usr/lib/dcv-socket-ns.so"
