## help: print this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ":" | sed -e 's/^/  /'

## lint: runs golangci lint based on .golangci.yml configuration
.PHONY: lint
lint:
	@if ! test -f `go env GOPATH`/bin/mockery; then go get github.com/golang/mock/mockgen@v1.6.0 && go install github.com/golang/mock/mockgen@v1.6.0; fi
	golangci-lint run -c .golangci.yml  --fix -v

## test: runs tests
.PHONY: test
test:
	go test -v ./... -coverprofile=unit_coverage.out -short

## unit-coverage-html: extract unit tests coverage to html format
.PHONY: unit-coverage-html
unit-coverage-html:
	make test
	go tool cover -html=unit_coverage.out -o unit_coverage.html

exceptionTopicName = 'exception'

## produce: produce test message (requires jq and kafka-console-producer)
.PHONY: produce
produce:
	jq -rc . internal/exception/testdata/message.json | kafka-console-producer --bootstrap-server 127.0.0.1:9092 --topic ${exceptionTopicName}

## produce: produce test message with retry header (requires jq and kcat)
.PHONY: produce-with-header
produce-with-header:
	jq -rc . internal/exception/testdata/message.json | kcat -b 127.0.0.1:9092 -t ${exceptionTopicName} -P -H x-retry-count=1