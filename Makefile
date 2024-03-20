DOCKER := $(shell command -v docker 2> /dev/null)


.PHONY: build

build:
ifndef DOCKER
	$(error "docker is not available; please install it")
endif
	$(DOCKER) build -f containers/pgml/Dockerfile -t pgml:latest containers/pgml/
	$(DOCKER) build -f containers/pgml-dashboard/Dockerfile -t pgml:latest containers/pgml-dashboard/
