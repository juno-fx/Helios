.PHONY: jammy

jammy:
	docker compose build --build-arg DISTRO=ubuntu --build-arg TAG=jammy
	docker compose up

