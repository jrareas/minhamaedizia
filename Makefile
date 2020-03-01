# Defaults settings (when building locally)
SHELL := /bin/sh

GCP_REGISTRY=gcr.io/minhamaedizia
IMAGE_NAME=$(GCP_REGISTRY)/minhamaedizia

-include variables.sh

variables.sh: ##
	unzip -o -P $(ZIP_SECRET) variables.zip
	variables.sh


help:	 ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fg

build:   ## build the image
	#unzip -o -P $(ZIP_SECRET) variables.zip
	#include variables.sh
	docker build \
		--build-arg magento_db_host=$(magento_db_host) \
		--build-arg magento_db_name=$(magento_db_name) \
		--build-arg magento_db_user=$(magento_db_user) \
		--build-arg magento_db_pass=$(magento_db_pass) \
		-t $(IMAGE_NAME) .

push:    ## push the image to the docker registry
	docker push $(IMAGE_NAME)

tag: ## Tag the built image with the tag name (make tag TAG_VER=xxx)
	docker tag $(IMAGE_NAME) $(IMAGE_NAME)

pull:    ## pull an image from the docker registry
	docker pull $(IMAGE_NAME):$(TAG_NAME)

update: ## Update the code for all repositories
	docker run \
	  -v $(PWD)/tulip.yaml:/workspace/tulip.yaml \
	  -v $(PWD)/tulip.lock:/workspace/tulip.lock \
	  -e USER_ID=$(HOST_USER_ID) -e GROUP_ID=$(HOST_GROUP_ID) \
	  $(PLATFORM_BUILDER_IMAGE) oleander generate-lock

ci-build: build

ci-test:
	echo "no tests"
