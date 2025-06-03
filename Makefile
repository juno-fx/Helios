.PHONY: jammy kali noble rocky-9 alma-9

jammy:
	@docker compose build --build-arg IMAGE=ubuntu:jammy --build-arg SRC=jammy
	@docker compose up

noble:
	@docker compose build --build-arg IMAGE=ubuntu:noble --build-arg SRC=noble
	@docker compose up

kali:
	@docker compose build --build-arg IMAGE=kalilinux/kali-rolling:latest --build-arg SRC=kali
	@docker compose up

rocky-9:
	@docker compose build --build-arg IMAGE=rockylinux:9 --build-arg SRC=rocky-9 --build-arg RHEL=true
	@docker compose up

alma-9:
	@docker compose build --build-arg IMAGE=almalinux:9 --build-arg SRC=alma-9 --build-arg RHEL=true
	@docker compose up

format:
	@shfmt -l -w .
