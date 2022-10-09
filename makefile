#!/usr/bin/env bash
PROJECT=bumble_bot

build up start stop down push pull :
	DOCKER_BUILDKIT=1 docker-compose $@

deploy:
	DOCKER_BUILDKIT=1 docker-compose up -d --build

docker_build:
	DOCKER_BUILDKIT=1 docker build . -t $(PROJECT)

docker_run:
	docker run -it --network host -v $(shell pwd):/opt/bumble_bot $(PROJECT)

docker_bash:
	docker run -it --network host -v $(shell pwd):/opt/bumble_bot $(PROJECT) bash

docker_test:
	docker run -it --network host -v $(shell pwd):/opt/bumble_bot $(PROJECT) pytest --cov-report term-missing --cov=bumble_bot tests/


