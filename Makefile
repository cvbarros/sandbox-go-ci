.PHONY: build build-alpine clean test help default

export GO111MODULE=on
BIN_NAME=sandbox-go-ci

VERSION := $(shell grep "const Version " version/version.go | sed -E 's/.*"(.+)"$$/\1/')
GIT_COMMIT=$(shell git rev-parse HEAD)
GIT_DIRTY=$(shell test -n "`git status --porcelain`" && echo "+CHANGES" || true)
BUILD_DATE=$(shell date '+%Y-%m-%d-%H:%M:%S')
IMAGE_NAME := "cvbarros/sandbox-go-ci"

default: test

help:
	@echo 'Management commands for sandbox:'
	@echo
	@echo 'Usage:'
	@echo '    make build           Compile the project.'
	@echo '    make get-deps        runs dep ensure, mostly used for ci.'
	
	@echo '    make clean           Clean the directory tree.'
	@echo

build:
	@echo "building ${BIN_NAME} ${VERSION}"
	@echo "GOPATH=${GOPATH}"
	go build -ldflags "-X github.com/cvbarros/sandbox-go-ci/version.GitCommit=${GIT_COMMIT}${GIT_DIRTY} -X github.com/cvbarros/sandbox-go-ci/version.BuildDate=${BUILD_DATE}" -o bin/${BIN_NAME}

builder-action:
	docker run --rm -e GITHUB_WORKSPACE='/github/workspace' -e GITHUB_REPOSITORY='sandbox-go-ci' -e GITHUB_REF='v0.0.1' --name sandbox-go-ci-builder cvbarros/sandbox-go-ci-builder:latest

clean:
	@test ! -e bin/${BIN_NAME} || rm bin/${BIN_NAME}

test:
	go test ./...

