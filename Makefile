SOURCE_FILES?=$$(go list ./... | grep -v /vendor/ | grep -v /mocks/)
TEST_PATTERN?=.
TEST_OPTIONS?=-race -v

setup:
	go get -u github.com/alecthomas/gometalinter
	go get -u github.com/pierrre/gotestcover
	go get -u golang.org/x/tools/cmd/cover
	gometalinter --install --update

test:
	gotestcover $(TEST_OPTIONS) -covermode=atomic -coverprofile=coverage.txt $(SOURCE_FILES) -run $(TEST_PATTERN) -timeout=30s

cover: test
	go tool cover -html=coverage.txt

fmt:
	find . -name '*.go' -not -wholename './vendor/*' | while read -r file; do gofmt -w -s "$$file"; goimports -w "$$file"; done

lint:
	gometalinter -e testing.go -e validation_test.go --vendor --disable-all \
		--enable=deadcode \
		--enable=gocyclo \
		--enable=errcheck \
		--enable=gofmt \
		--enable=goimports \
		--enable=golint \
		--enable=gosimple \
		--enable=ineffassign \
		--enable=misspell \
		--enable=unconvert \
		--enable=varcheck \
		--enable=staticcheck \
		--enable=unparam\
		--enable=varcheck \
		--enable=dupl \
		--enable=structcheck \
		--enable=vetshadow \
		--deadline=10m \
		./...

ci: lint test

BUILD_TAG := $(shell git describe --tags 2>/dev/null)
BUILD_SHA := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u '+%Y/%m/%d:%H:%M:%S')

critic:
	gocritic check-project .

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := build
