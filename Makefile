
BIN_OUTPUT_PATH = bin
TOOL_BIN = bin/gotools/$(shell uname -s)-$(shell uname -m)
UNAME_S ?= $(shell uname -s)

build:
	rm -f $(BIN_OUTPUT_PATH)/galil
	go build $(LDFLAGS) -o $(BIN_OUTPUT_PATH)/galil main.go

module.tar.gz: build
	rm -f $(BIN_OUTPUT_PATH)/module.tar.gz
	tar czf $(BIN_OUTPUT_PATH)/module.tar.gz $(BIN_OUTPUT_PATH)/galil meta.json

galil: *.go 
	go build -o galil *.go

test: 
	go test ./..

clean:
	rm -rf $(BIN_OUTPUT_PATH)/galil $(BIN_OUTPUT_PATH)/module.tar.gz galil

gofmt:
	gofmt -w -s .

lint: gofmt
	go mod tidy

update-rdk:
	go get go.viam.com/rdk@latest
	go mod tidy
