NS ?= azch
IMAGE_NAME ?= site
VERSION ?= latest
PORTS = -p 8080:80

.PHONY: build run

build: Dockerfile
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

run:
	docker run --rm $(PORTS) $(NS)/$(IMAGE_NAME):$(VERSION)

build-run:
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile . && docker run --rm $(PORTS) $(NS)/$(IMAGE_NAME):$(VERSION)