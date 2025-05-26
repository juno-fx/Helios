# heavily refernces https://github.com/linuxserver/docker-baseimage-kasmvnc/blob/master/Dockerfile
ARG DISTRO
ARG TAG

FROM ${DISTRO}:${TAG} AS distro


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
RUN tar -C /s6 -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && unlink /s6/usr/bin/with-contenv
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C /s6 -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz


FROM node:20 AS novnc

# https://github.com/kasmtech/noVNC/tree/bed156c565f7646434563d2deddd3a6c945b7727
ENV KASMWEB_COMMIT="bed156c565f7646434563d2deddd3a6c945b7727"

ENV QT_QPA_PLATFORM=offscreen
ENV QT_QPA_FONTDIR=/usr/share/fonts

# Build kasm noVNC client base
COPY --chmod=777 common/kasm/novnc.sh /
RUN /novnc.sh


# kasm build environment
FROM distro AS kasm-build

# https://github.com/kasmtech/KasmVNC/tree/e647af5e281735d1c7fc676ca089201aeae7130a
ENV KASMVNC_COMMIT="e647af5e281735d1c7fc676ca089201aeae7130a"
ENV KASMBINS_RELEASE="1.15.0"

# pull in args for the tag
ARG TAG

# setup build environment
WORKDIR /build

# copying individually as to allow for change caching
# running individually as to keep the cache in case of failure and for debugging
COPY --chmod=777 ${TAG}/kasm/dependencies.sh /build/
RUN ./dependencies.sh
COPY --chmod=777 common/kasm/turbo.sh /build/
RUN ./turbo.sh
COPY --chmod=777 common/kasm/kasm.sh /build/
RUN ./kasm.sh
COPY --chmod=777 ${TAG}/kasm/xorg.sh /build/
RUN ./xorg.sh
COPY --chmod=777 ${TAG}/kclient/dependencies.sh /build/
RUN ./dependencies.sh
COPY --chmod=777 common/kclient/build.sh /build/
COPY --chmod=777 common/kclient/helios.patch /build/
RUN ./build.sh

# copy over the built noVNC client
COPY --from=novnc /build-out /www

# package up the server for distribution
COPY --chmod=777 common/kasm/package.sh /build/
RUN ./package.sh


# base image
FROM distro AS base-image

# pull in args for the tag
ARG TAG

# build our base image
COPY --chmod=777 ${TAG}/system/install.sh /tmp/
RUN /tmp/install.sh

# install init system
COPY --from=s6 /s6 /
COPY --from=kasm-build /build-out/ /

# environment variables
ENV PREFIX=/
ENV HTTP_PORT=3000
ENV DISPLAY=:1
ENV PERL5LIB=/usr/local/bin
ENV PULSE_RUNTIME_PATH=/defaults
ENV NVIDIA_DRIVER_CAPABILITIES=all

# copy in our custom rootfs changes
COPY root/ /

RUN chmod -R 7777 /etc/s6-overlay/s6-rc.d/

EXPOSE 3000

CMD ["/init"]
