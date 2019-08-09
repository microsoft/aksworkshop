NS ?= azch
IMAGE_NAME ?= aks-site
VERSION ?= latest
LOCALPORT = 8080
CONTAINERPORT = 80
PORTS = -p $(LOCALPORT):$(CONTAINERPORT)

.PHONY: build run

build: Dockerfile
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

run:
	docker run --rm $(PORTS) $(NS)/$(IMAGE_NAME):$(VERSION)

build-run:
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .
	echo http://localhost:$(LOCALPORT)
	docker run --rm $(PORTS) $(NS)/$(IMAGE_NAME):$(VERSION)
