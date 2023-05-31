#
# Version 0.0.1 - 08/27/2020
# Source: https://git.corp.nextdoor.com/Nextdoor/ecr-subsys
#
ROOT_DIR      := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# The AWS_BIN variable can be overridden by the calling Makefile if they have
# their own location for it. As long as the binary exists, we're good.
AWS_BIN       ?= $(shell which aws || echo aws)

# The repository name should be easy enough to get - We append the .git so that
# we are matching exactly how it looks in Github.
_REPO_NAME         := $(shell basename `git config --get remote.origin.url` 2>/dev/null || pwd)
REPO_NAME          := $(shell basename -s .git $(_REPO_NAME))

# Repo information that informs our tags
SHA1               := $(shell git rev-parse --short HEAD)
BRANCH             := $(shell basename $(shell git symbolic-ref HEAD))

# see go/ecr
ECR_REGION         := us-west-2
ECR_ACCOUNT_ID     := 364942603424
ECR_REGISTRY       := $(ECR_ACCOUNT_ID).dkr.ecr.$(ECR_REGION).amazonaws.com
ECR_NAMESPACE      ?= nextdoor

# When doing Kubernetes development, we use "kind" to run clusters locally and
# in our CI systems. The standard cluster-name is "default". We have a few
# hooks in this Docker build process to help you side-load your locally built
# images into the Kubernetes cluster.
KIND               ?= $(shell which kind || echo kind)
KIND_CLUSTER_NAME  ?= default

# This setup builds consistent DOCKER_TAG logic that we simplifies our build
# processes and reduces the amount of clutter in our .circle/config.yaml
# files.
#
# On master/main branch builds, we always use the "main-$SHA1" tag. Period.
# On production branch builds, we use "release-$SHA1".
# On any other branch build, we use "test-$SHA1"
# On any build where $CIRCLE_TAG is set, we use "release-$CIRCLE_TAG".
#
# At any point, if DOCKER_TAG was set outside of this Makefile, then go ahead
# and use that value.
ifeq ($(CIRCLE_TAG),)
  ifeq ($(BRANCH),main)
    DOCKER_TAG ?= main-$(SHA1)
  endif
  ifeq ($(BRANCH),master)
    DOCKER_TAG ?= main-$(SHA1)
  endif
  ifeq ($(BRANCH),production)
    DOCKER_TAG ?= release-$(SHA1)
  else
    DOCKER_TAG ?= test-$(SHA1)
  endif
else
  DOCKER_TAG ?= release-$(CIRCLE_TAG)
endif

# Docker Build Flags
DOCKER             ?= $(shell which docker)
DOCKERFILE         ?= .
DOCKER_IMAGE       := $(REPO_NAME)
DOCKER_NAME        ?= $(ECR_NAMESPACE)/$(DOCKER_IMAGE):$(DOCKER_TAG)
DOCKER_FQDN        ?= $(ECR_REGISTRY)/$(DOCKER_NAME)

# This is a simple attempt to install the missing awscli command if it cannot
# be found. It's better for the virtual environment to already be loaded up (or
# the awscli to be installed via Apt) ahead of this..
aws_bin: $(AWS_BIN)
$(AWS_BIN):
	pip install awscli

# This target is primarily used by CircleCI - local developers should already
# have the ecr-login helper in place.
.PHONY: ecr_login
ecr_login: $(AWS_BIN)
	@echo "Getting Amazon ECR Credentials..."
	$(AWS_BIN) --region $(ECR_REGION) ecr get-login-password | \
		docker login --username AWS --password-stdin $(ECR_ACCOUNT_ID).dkr.ecr.$(ECR_REGION).amazonaws.com

.PHONY: docker_pull
docker_pull:
	$(DOCKER) pull $(DOCKER_FQDN)
	$(DOCKER) tag $(DOCKER_FQDN) $(DOCKER_IMAGE)

.PHONY: docker_build
docker_build:
	$(DOCKER) build $(DOCKERFILE) \
		-t $(DOCKER_IMAGE) \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		-t $(DOCKER_NAME) \
		-t $(DOCKER_FQDN)

.PHONY: docker_tag
docker_tag:
	$(DOCKER) tag $(DOCKER_IMAGE) $(DOCKER_FQDN)

.PHONY: docker_push
docker_push: docker_tag
	$(DOCKER) push $(DOCKER_FQDN)

.PHONY: docker_sideload
docker_sideload:
	@if [ ! -x $(KIND) ]; then echo 'Missing "kind" binary. Try "make tools"?'; exit 1; fi
	$(DOCKER) tag "$(DOCKER_FQDN)" "$(DOCKER_IMAGE):local" && \
		$(KIND) load docker-image --name "$(KIND_CLUSTER_NAME)" "$(DOCKER_IMAGE):local"
