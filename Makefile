SHELL := /bin/bash

.PHONY: docs jammy kali noble rocky-9 alma-9 bookworm sid alpine-3 packages

# documentation
docs: .venv/bin/activate
	.venv/bin/mkdocs serve

# we use realpath, as some of our runners symlink the storage. linkchecker doesn't like that
lint-docs: .venv/bin/activate
	@(grep -q -r '<a href' docs && (echo Please use markdown links instead of href. && exit 1)) || true
	([[ -d site ]] && rm -rf site/) || true
	.venv/bin/mkdocs build --strict
	cp -r site /tmp/site-terra-official-docs
	@ # This is due to some CI environments providing root as default.
	@ # linkchecker will drop to the `nobody` user. Depending on the workdir, it might not be able to reach it and will fail.
	([[ "$$EUID" -eq 0 ]] && chmod -R 655 /tmp/site-terra-official-docs) || true
	source .venv/bin/activate; linkchecker /tmp/site-terra-official-docs/index.html

# when using devbox, this will already exist and not trigger
# It's used by the CI, where devbox hook behavior is different
.venv/bin/activate:
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt
# development
format:
	@shfmt -l -w .

packages:
	@python ./hack/packages.py $(shell pwd)/packages/ $(shell pwd)/.packages/

build-all:
	@docker build . --build-arg IMAGE=debian:bookworm --build-arg SRC=bookworm -t bookworm
	@docker build . --build-arg IMAGE=debian:sid --build-arg SRC=sid -t sid
	@docker build . --build-arg IMAGE=kalilinux/kali-rolling:latest --build-arg SRC=kali -t kali
	@docker build . --build-arg IMAGE=ubuntu:jammy --build-arg SRC=jammy -t jammy
	@docker build . --build-arg IMAGE=ubuntu:noble --build-arg SRC=noble -t noble
	@docker build . --build-arg IMAGE=rockylinux:9 --build-arg SRC=rocky-9 -t rocky-9
	@docker build . --build-arg IMAGE=almalinux:9 --build-arg SRC=alma-9 -t alma-9

# DEBIAN
bookworm:
	@docker compose build --build-arg IMAGE=debian:bookworm --build-arg SRC=bookworm
	@docker compose up

sid:
	@docker compose build --build-arg IMAGE=debian:sid --build-arg SRC=sid
	@docker compose up

kali:
	@docker compose build --build-arg IMAGE=kalilinux/kali-rolling:latest --build-arg SRC=kali
	@docker compose up

# UBUNTU
jammy:
	@docker compose build --build-arg IMAGE=ubuntu:jammy --build-arg SRC=jammy
	@docker compose up

noble:
	@docker compose build --build-arg IMAGE=ubuntu:noble --build-arg SRC=noble
	@docker compose up

# RHEL
rocky-9:
	@docker compose build --build-arg IMAGE=rockylinux:9 --build-arg SRC=rocky-9
	@docker compose up

alma-9:
	@docker compose build --build-arg IMAGE=almalinux:9 --build-arg SRC=alma-9
	@docker compose up

