# Make all targets .PHONY
.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

SHELL = /usr/bin/env bash
USER_NAME = $(shell whoami)
USER_ID = $(shell id -u)
# GROUP_ID = $(shell id -g)
HOST_NAME = $(shell hostname)

ifeq (, $(shell which docker-compose))
	DOCKER_COMPOSE_COMMAND = docker compose
else
	DOCKER_COMPOSE_COMMAND = docker-compose
endif

DIRS_TO_VALIDATE = project
SERVICE_NAME = ml-service
CONTAINER_NAME = ml-trainer-container

DOCKER_COMPOSE_RUN = $(DOCKER_COMPOSE_COMMAND) run --rm $(SERVICE_NAME)
DOCKER_COMPOSE_EXEC = $(DOCKER_COMPOSE_COMMAND) exec $(SERVICE_NAME)

# ------ THIS IS KEY ----
# you need use `export` otherwise the variables are not available in the docker-compose.yaml
# It took me long time to figure this out. 
export

## Builds docker image
build:
	$(DOCKER_COMPOSE_COMMAND) build $(SERVICE_NAME)

up:
	$(DOCKER_COMPOSE_COMMAND) up -d

down:
	$(DOCKER_COMPOSE_COMMAND) down

## enter container with bash shell
exec-in: up
	docker exec -it $(CONTAINER_NAME) bash

## Starts jupyter lab
# This does not work - it has to do with permission 
# you can make it work using `--user root` and `--allow-user`
# note that we use a different from default port.
# port 8080 is exposed in the docker-compose.yaml
notebook: up
	$(DOCKER_COMPOSE_EXEC) jupyter-lab --ip 0.0.0.0 --port 8080 --no-browser

## Lint code using flake8
lint: up # format-check sort-check
	$(DOCKER_COMPOSE_EXEC) flake8 $(DIRS_TO_VALIDATE)

## Sort code using isort
format: up
	$(DOCKER_COMPOSE_EXEC) black $(DIRS_TO_VALIDATE)

## Sort code using isort
sort: up
	$(DOCKER_COMPOSE_EXEC) isort --atomic $(DIRS_TO_VALIDATE)

format-and-sort: sort format

## Check type annotations using mypy
check-type-annotations: up
	$(DOCKER_COMPOSE_EXEC) mypy $(DIRS_TO_VALIDATE)

## train model by executing main.py
train: up
	$(DOCKER_COMPOSE_EXEC) python project/main.py

## initialize dvc
version-data: up
	$(DOCKER_COMPOSE_EXEC) python project/version_data.py

help:
	@echo $(SHELL)
	@echo $(USER_NAME)
	@echo $(DOCKER_COMPOSE_COMMAND)

