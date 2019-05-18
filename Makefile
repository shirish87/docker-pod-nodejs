
# root/
# |_ app/
# |  |_ Dockerfile
# |  |_ secrets.env
# |  |_ secrets.dev.env
# |_ web/
# |  |_ Dockerfile
# |  |_ secrets.env
# |  |_ secrets.dev.env
# |_ project.env	(PROJECT_NAME=project_1)
# |_ docker-compose.yml
# |_ docker-compose.dev.yml

app ?= app
proj ?= project.env
include $(proj)
export $(shell sed 's/=.*//' $(proj))

.PHONY: help

help:		## Show list of targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

PROJECT_NAME ?= $(COMPOSE_PROJECT_NAME)
DOCKER_COMPOSE_FILE := docker-compose.yml
LOGS_TAIL := 200

--dev:
	$(eval PROJECT_NAME := $(PROJECT_NAME)-dev)
	$(eval DOCKER_COMPOSE_FILE := docker-compose.dev.yml)

ifeq (,$(wildcard $(DOCKER_COMPOSE_FILE)))
	$(error "$(DOCKER_COMPOSE_FILE) does not exist.")
endif

build:		## Build project containers
	@docker-compose -f "$(DOCKER_COMPOSE_FILE)" -p "$(PROJECT_NAME)" build

build-dev: --dev build		## Build DEV project containers

start:		## Start all project containers
	@docker-compose -f "$(DOCKER_COMPOSE_FILE)" -p "$(PROJECT_NAME)" up -d

start-dev: --dev start		## Start all DEV project containers

stop:		## Stop all project containers
	@docker-compose -f "$(DOCKER_COMPOSE_FILE)" -p "$(PROJECT_NAME)" stop

stop-dev: --dev stop		## Stop all DEV project containers

status:		## Display status of project containers
	@docker ps -f name="$(PROJECT_NAME)"

status-dev: --dev status		## Display status of DEV project containers

logs:		## Display logs of all project containers
	-@docker-compose -f "$(DOCKER_COMPOSE_FILE)" -p "$(PROJECT_NAME)" logs --follow --tail $(LOGS_TAIL)

logs-dev: --dev logs		## Display logs of all DEV project containers

deploy: build stop start status		## Build and restart project containers

deploy-dev: build-dev stop-dev start-dev status-dev		## Build and restart DEV project containers

destroy:		## Remove all project containers
	@docker-compose -f "$(DOCKER_COMPOSE_FILE)" -p "$(PROJECT_NAME)" down --remove-orphans

destroy-dev: --dev destroy		## Remove all DEV project containers

shell:
	@INSTANCE="$(shell docker ps --format '{{.ID}}\t{{.Image}}\t{{.Names}}' -f ancestor='$(PROJECT_NAME)_$(app)' | grep -w '$(PROJECT_NAME)_$(app)' | awk '{ print $$1 }')"; \
		(test -n "$$INSTANCE" || { echo "$(PROJECT_NAME)_$(app)> ERROR: App \"$(app)\" not found. Please specify a valid app name."; exit 1; }) && \
		echo "$(PROJECT_NAME)_$(app):$$INSTANCE>" && \
		docker exec -i -t $${INSTANCE:?} /bin/bash

shell-dev: --dev shell
