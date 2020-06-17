SHELL := /bin/bash

MODULE         := $(notdir $(PWD))
USERID          = $(shell id -u)
USERGROUP       = $(shell id -g)
DATE_TIME       = $(shell date +%s)
GCP_CREDS_FILE  = $(notdir ${GOOGLE_CREDENTIALS})

.PHONY: readme test

clear-env-error:
	$(eval ENV_ERROR =)

check-error:
	@if [ ! "${ENV_ERROR}" = "" ]; then echo -e "${ENV_ERROR}" && exit 1; fi

check-env:
ifeq ($(GOOGLE_CREDENTIALS), )
	$(eval ENV_ERROR = $(ENV_ERROR)GOOGLE_CREDENTIALS is not set in environment.\n)
endif
ifeq ($(GOOGLE_CLOUD_PROJECT), )
	$(eval ENV_ERROR = $(ENV_ERROR)GOOGLE_CLOUD_PROJECT is not set in environment.\n)
endif

check-gcp-env: clear-env-error check-env check-error

test: check-gcp-env $(GOOGLE_CREDENTIALS)
	docker run --rm -it \
	-v ${GOOGLE_CREDENTIALS}:/root/$(GCP_CREDS_FILE):ro \
	-v $(PWD):/go/src/app/ \
	-e GOOGLE_APPLICATION_CREDENTIALS=/root/$(GCP_CREDS_FILE) \
	-e GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT} \
	-e TF_VAR_owner=$(USER) \
	binxio/terratest-runner-gcp:latest

readme:
	docker run --rm -e MODULE=$(MODULE) --user $(USERID):$(USERGROUP) -it -v $(PWD):/go/src/app/$(MODULE) binxio/terraform-module-readme-generator:latest
