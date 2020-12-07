IMAGE_REGISTRY := docker.io
IMAGE_ORG := marccarre
IMAGE_NAME := linter
IMAGE_TAG := $(shell ./bin/revision)
IMAGE := $(IMAGE_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME)

VCS_REF := $(shell git rev-parse HEAD)
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
CURRENT_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := all
.PHONY: all
all: clean build test

.PHONY: build
build:
	docker build \
		-t $(IMAGE):$(IMAGE_TAG) -t $(IMAGE):latest \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		$(CURRENT_DIR)

.PHONY: test
test:
	# Linting ourselves is a good first test:
	docker run -v $(CURRENT_DIR):/mnt/lint $(IMAGE):$(IMAGE_TAG)

.PHONY: debug
debug:
	docker run -v $(CURRENT_DIR):/mnt/lint -it $(IMAGE):$(IMAGE_TAG) sh

.PHONY: push
push:
	docker push $(IMAGE):$(IMAGE_TAG)
	docker push $(IMAGE):latest

.PHONY: clean
clean:
	docker rmi -f \
		$(IMAGE):$(IMAGE_TAG) \
		$(IMAGE):latest
