.PHONY: image publish tag vars

ACCOUNT?=$(shell aws sts get-caller-identity | jq -r .Account)
NAME?=$(shell awk -F: '$$1=="name" {print $$2}' deployment.yaml | sed -e 's/\s//g')
ECR?=${ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com
IMAGE?=${NAME}
REPO?=${ECR}/${IMAGE}

BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
COMMIT:=$(shell git rev-parse --short HEAD)
VERSION:=1.5.0
TAG?=${VERSION}

all: publish

image:
	@echo Building ${IMAGE}:${TAG} ...
	@docker build \
    --build-arg build_date=`date -Iseconds` \
    --build-arg image_name=${IMAGE} \
    --build-arg git_branch=${BRANCH} \
    --build-arg git_commit_hash=${COMMIT} \
		--build-arg github_run_number=${GITHUB_RUN_NUMBER} \
		--build-arg version=${VERSION} \
		-t ${IMAGE}:${TAG} . 
	@echo Tagging ${IMAGE}:latest ...
	@docker tag ${IMAGE}:${TAG} ${IMAGE}:${VERSION}
	@docker tag ${IMAGE}:${TAG} ${IMAGE}:latest

publish: image
	@echo Tagging ${REPO}:${TAG} ...
	@docker tag ${IMAGE}:${TAG} ${REPO}:${TAG}
	@echo Publishing ${REPO}:${TAG} ...
	@docker push ${REPO}:${TAG}
	@echo Done.

tag:
	@echo ${TAG}

vars:
	@echo NAME:${NAME}
	@echo VERSION:${VERSION}
	@echo BRANCH:${BRANCH}
	@echo COMMIT:${COMMIT}
	@echo IMAGE:${IMAGE}
	@echo REPO:${REPO}
	@echo TAG:${TAG}
