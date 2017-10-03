GO_LINT := $(GOPATH)/bin/golint
GO_BINDATA := $(GOPATH)/bin/go-bindata
DATA_FILES := ./utilities/openapi.yaml ./utilities/contribute.yaml
SRC := *.go ./utilities/*.go ./warden/*.go
PACKAGES := ./ ./utilities/ ./warden/

main: utilities/bindata.go $(SRC)
	CGO_ENABLED=0 go build -o main *.go

clean:
	rm -f main coverage.txt utilities/bindata.go

$(GO_BINDATA):
	go get github.com/jteeuwen/go-bindata/...

utilities/bindata.go: $(GO_BINDATA) $(DATA_FILES)
	$(GO_BINDATA) -o utilities/bindata.go -pkg utilities $(DATA_FILES)

policies.yaml:
	touch policies.yaml

serve: main policies.yaml
	./main

$(GO_LINT):
	go get github.com/golang/lint/golint

lint: $(GO_LINT)
	$(GO_LINT) $(PACKAGES)
	go vet $(PACKAGES)

fmt:
	gofmt -w -s $(SRC)

test: policies.yaml utilities/bindata.go lint
	go test -v $(PACKAGES)

test-coverage: policies.yaml utilities/bindata.go
	# Multiple package coverage script from https://github.com/pierrre/gotestcover
	echo 'mode: atomic' > coverage.txt && go list ./... | grep -v /vendor/ | xargs -n1 -I{} sh -c 'go test -v -covermode=atomic -coverprofile=coverage.tmp {} && tail -n +2 coverage.tmp >> coverage.txt' && rm coverage.tmp
	# Exclude bindata.go from coverage.
	sed -i '/bindata.go/d' coverage.txt

docker-build: main
	docker build -t mozilla/iam .

docker-run:
	docker run --name iam --rm mozilla/iam
