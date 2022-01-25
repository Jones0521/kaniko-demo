all: build

object=hello

build:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags "-s -w" -o $(object) main.go

.PHONY: clean
clean:
	rm hello 

