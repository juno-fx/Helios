ARG IMAGE=ubuntu:jammy
ARG SRC=jammy

FROM ${IMAGE} AS distro

ENV HELIOS_VERSION="0.0.0"
ENV HELIOS_XVFB_PATCH=21
ENV SRC=${SRC}



# s6 init system
FROM alpine AS s6

# install init system
ENV S6_VERSION="v3.2.1.0"

WORKDIR /s6

# install s6
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C /s6 -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C /s6 -Jxpf /tmp/s6-overlay-x86_64.tar.xz

# add s6 optional symlinks
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
RUN tar -C /s6 -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C /s6 -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz



# generate install lists
FROM python:alpine AS lists

WORKDIR /work

COPY hack/packages.py ./
COPY packages packages

RUN pip install pyyaml --break-system-packages \
    && python3 /work/packages.py /work/packages/ /work/lists/



# xvfb build stage
FROM distro AS xvfb

# pull in args for the tag
ARG SRC

# build xvfb
COPY patches/* /tmp/
COPY --chmod=777 ${SRC}/build/xvfb-dependencies.sh /tmp/
COPY --chmod=777 common/build/xvfb.sh /tmp/
RUN /tmp/xvfb.sh



# build selkies frontend
FROM alpine AS selkies-frontend

ENV SELKIES_VERSION="89e39cf7d58c8f7c87ac5922b56b84f745ddeeab"

# grab package lists
COPY --from=lists /work/lists/ /lists/

# build our frontend image
COPY --chmod=777 common/build/frontend.sh /tmp/frontend.sh
RUN apk add bash && /tmp/frontend.sh



FROM distro AS base-image

# version of selkies to clone
ENV SELKIES_VERSION="89e39cf7d58c8f7c87ac5922b56b84f745ddeeab"

# environment variables
ENV PREFIX=/
ENV HTTP_PORT=3000
ENV DISPLAY=:1
ENV PERL5LIB=/usr/local/bin
ENV PULSE_RUNTIME_PATH=/tmp/pulse
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV IDLE_TIME=30
ENV SELKIES_INTERPOSER=/usr/lib/selkies_joystick_interposer.so
ENV DISABLE_ZINK=false
ENV SELKIES_NODE_VERSION=22

# pull in args for the tag
ARG SRC

# grab package lists
COPY --from=lists /work/lists/ /lists/

# build our base image
COPY --chmod=777 ${SRC}/build/system.sh /tmp/
RUN /tmp/system.sh
COPY --chmod=777 common/build/system.sh /tmp/
RUN /tmp/system.sh

# install selkies
COPY --chmod=777 common/build/selkies/*.sh /tmp/
RUN /tmp/selkies.sh

# clean up package lists
RUN rm -rf /lists

# install init system
COPY --from=s6 /s6 /

# install custom xvfb (if needed)
COPY --from=xvfb /build-out/ /

# install selkies frontend
COPY --from=selkies-frontend /build-out/ /usr/share/selkies/www/

# copy in general custom rootfs changes
COPY common/root/ /

# LD_PRELOAD wrapper handlers (selkies hack)
RUN chmod +x /usr/bin/thunar

# copy in distro specific custom rootfs changes
COPY ${SRC}/root/ /

# set permissions
RUN chmod -R 7777 /etc/s6-overlay/s6-rc.d/

# add license file
COPY LICENSE /LICENSE

EXPOSE 3000
EXPOSE 3001

RUN rm -rf /.hold

CMD ["/init"]
