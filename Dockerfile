# heavily refernces https://github.com/linuxserver/docker-baseimage-kasmvnc/blob/master/Dockerfile
ARG IMAGE=ubuntu:jammy
ARG SRC=jammy
ARG RHEL=false

FROM ${IMAGE} AS distro


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

ARG RHEL

# https://github.com/kasmtech/noVNC/tree/bed156c565f7646434563d2deddd3a6c945b7727
ENV KASMWEB_COMMIT="bed156c565f7646434563d2deddd3a6c945b7727"
ENV QT_QPA_PLATFORM=offscreen
ENV QT_QPA_FONTDIR=/usr/share/fonts

# Build kasm noVNC client base
COPY --chmod=777 common/build/novnc.sh /
COPY --chmod=777 common/build/novnc-*.patch /
RUN /novnc.sh


# kasm build environment
FROM distro AS kasm-build

# https://github.com/kasmtech/KasmVNC/tree/e647af5e281735d1c7fc676ca089201aeae7130a
ENV KASMVNC_COMMIT="e647af5e281735d1c7fc676ca089201aeae7130a"
ENV KASMBINS_RELEASE="1.15.0"

# pull in args for the tag
ARG SRC

# setup build environment
WORKDIR /build

# copying individually as to allow for change caching
# running individually as to keep the cache in case of failure and for debugging
COPY --chmod=777 ${SRC}/build/kasm.sh /build/
RUN ./kasm.sh
COPY --chmod=777 common/build/turbo.sh /build/
RUN ./turbo.sh
COPY --chmod=777 common/build/kasm.sh /build/
RUN ./kasm.sh
COPY --chmod=777 ${SRC}/build/xorg.sh /build/
RUN ./xorg.sh
COPY --chmod=777 ${SRC}/build/kclient.sh /build/
RUN ./kclient.sh
COPY --chmod=777 common/build/kclient.sh /build/
COPY --chmod=777 common/build/kclient-05-02-2025.patch /build/
RUN ./kclient.sh

# copy over the built noVNC client
COPY --from=novnc /build-out /www

# package up the server for distribution
COPY --chmod=777 common/build/package.sh /build/
RUN ./package.sh

# copy over build version information
COPY --from=novnc /tmp/kasmweb.version /build-out/opt/helios/kasmweb.version


# generate the snake oil certificate
FROM ubuntu AS snake-oil
RUN apt update && apt install -y ssl-cert


# base image
FROM distro AS base-image

ENV HELIOS_VERSION="0.0.0"

# pull in args for the tag
ARG SRC

# build our base image
COPY --chmod=777 ${SRC}/build/system.sh /tmp/
RUN /tmp/system.sh

# install init system
COPY --from=s6 /s6 /
COPY --from=kasm-build /build-out/ /

# environment variables
ENV PREFIX=/
ENV HTTP_PORT=3000
ENV DISPLAY=:1
ENV PERL5LIB=/usr/local/bin
ENV PULSE_RUNTIME_PATH=/opt/helios/
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV IDLE_TIME=30

# copy in general custom rootfs changes
COPY common/root/ /

# copy in distro specific custom rootfs changes
COPY ${SRC}/root/ /

# set permissions
RUN chmod -R 7777 /etc/s6-overlay/s6-rc.d/

# this is to ensure that the snake oil certificate is available for Kasm
COPY --from=snake-oil /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/ssl-cert-snakeoil.pem
COPY --from=snake-oil /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/ssl-cert-snakeoil.key

EXPOSE 3000

CMD ["/init"]
