IMAGE_NAME ?= secure-squid-chainguard
IMAGE_TAG ?= latest
IMAGE ?= $(IMAGE_NAME):$(IMAGE_TAG)
BASE_IMAGE ?= cgr.dev/chainguard/squid-proxy:latest
CHAINGUARD_ORG ?=
DIST_DIR ?= dist
TARBALL ?= $(DIST_DIR)/secure-squid-chainguard.tar
GZ_TARBALL ?= $(TARBALL).gz
CONTAINER_NAME ?= secure-squid-chainguard

.PHONY: build build-fips run test scan save clean

build:
	docker build --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(IMAGE) .

build-fips:
	@if [ -z "$(CHAINGUARD_ORG)" ]; then \
		echo "CHAINGUARD_ORG is required for the private FIPS image"; \
		echo "Example: make build-fips CHAINGUARD_ORG=my-org"; \
		exit 1; \
	fi
	docker build -f Dockerfile.fips --build-arg CHAINGUARD_ORG=$(CHAINGUARD_ORG) -t $(IMAGE_NAME)-fips:$(IMAGE_TAG) .

run:
	docker run --rm --name $(CONTAINER_NAME) -p 3128:3128 $(IMAGE)

test:
	IMAGE=$(IMAGE) ./test/smoke-test.sh

scan:
	trivy image --exit-code 1 --severity HIGH,CRITICAL $(IMAGE)

save:
	mkdir -p $(DIST_DIR)
	docker save $(IMAGE) -o $(TARBALL)
	gzip -f $(TARBALL)
	@echo "Wrote $(GZ_TARBALL)"

clean:
	rm -rf $(DIST_DIR)
