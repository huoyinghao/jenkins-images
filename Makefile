VERSION?=""
ifeq ($(VERSION), "")
    LATEST_TAG=$(shell git describe --tags --abbrev=8)
    ifeq ($(LATEST_TAG),)
        VERSION="unknown"
    else
        VERSION=$(LATEST_TAG)
    endif
endif

JENKINS_VERSION="2.346.2"
# REGISTRY_REPO?="release.daocloud.io"
REGISTRY_REPO?="huoyinghao"
REGISTRY_CI_REPO?="release-ci.daocloud.io"
TAG=$(VERSION)-$(JENKINS_VERSION)
BUILD_ARCH?="linux/amd64,linux/arm64"
AMAMBA_IMAGE_VERSION=$(VERSION)

.PHONY: build-jenkins-all
build-jenkins-all: docker-login build-amd64 build-arm64 #这个过程不能设为并发,一定要保证build-amd64执行成功之后再执行build-arm64 所以在make的时候不要指定-j 参数

.PHONY: build-amd64
build-amd64:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
    ! ( docker buildx ls | grep amamba-jenkins-amd64-multi-platform-builder ) && docker buildx create --use --platform=linux/amd64 --name amamba-jenkins-amd64-multi-platform-builder ;\
	docker buildx build \
    	   --builder amamba-jenkins-amd64-multi-platform-builder \
    	   --platform linux/amd64 \
    	   --tag $(REGISTRY_REPO)/jenkins:$(TAG)-amd64  \
    	   --tag $(REGISTRY_REPO)/jenkins:latest-amd64  \
    	   -f Dockerfile \
    	   --push \
    	   .

.PHONY: build-arm64
build-arm64:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
    ! ( docker buildx ls | grep amamba-jenkins-arm64-multi-platform-builder ) && docker buildx create --use --platform=linux/arm64 --name amamba-jenkins-arm64-multi-platform-builder ;\
	docker buildx build \
    	   --builder amamba-jenkins-arm64-multi-platform-builder \
    	   --platform linux/arm64 \
    	   --tag $(REGISTRY_REPO)/jenkins:$(TAG)-arm64  \
    	   --tag $(REGISTRY_REPO)/jenkins:latest-arm64  \
    	   --build-arg REGISTRY_REPO=$(REGISTRY_REPO) \
    	   -f ./build/Dockerfile \
    	   --build-arg TAG=$(TAG) \
    	   --push \
    	   .

.PHONY: build-manifest
build-manifest:
	docker manifest create $(REGISTRY_REPO)/jenkins:$(TAG) $(REGISTRY_REPO)/jenkins:$(TAG)-amd64 $(REGISTRY_REPO)/jenkins:$(TAG)-arm64
	docker manifest push $(REGISTRY_REPO)/jenkins:$(TAG)

.PHONY: docker-login
docker-login:
	@echo "push images to $(REGISTRY_REPO)"
	#docker login ${REGISTRY_REPO} -u ${REGISTRY_USERNAME} -p ${REGISTRY_PASSWORD}
	docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}

.PHONY: build-jenkins-agent-base-all
build-jenkins-agent-base-all: build-jenkins-agent-base-podman

.PHONY: build-jenkins-agent-base
build-jenkins-agent-base:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	export BUILDKIT_PROGRESS=plain ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-base-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-base-multi-platform-builder ;\
	docker buildx build --progress=plain \
			--builder amamba-jenkins-agent-base-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-base:$(AMAMBA_IMAGE_VERSION)  \
			--tag $(REGISTRY_REPO)/jenkins-agent-base:latest  \
			-f ./jenkins-agent/base/Dockerfile \
			--push \
			./jenkins-agent/base

.PHONY: build-jenkins-agent-base-podman
build-jenkins-agent-base-podman: build-jenkins-agent-base
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	export BUILDKIT_PROGRESS=plain ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-base-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-base-podman-multi-platform-builder ;\
	docker buildx build --progress=plain \
			--builder amamba-jenkins-agent-base-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-base:$(AMAMBA_IMAGE_VERSION)-podman  \
			--tag $(REGISTRY_REPO)/jenkins-agent-base:latest-podman  \
			-f ./jenkins-agent/base/podman/Dockerfile \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/base

.PHNOY: build-jenkins-agent-go-all
build-jenkins-agent-go-all: build-jenkins-agent-go build-jenkins-agent-go-podman

.PHONY: build-jenkins-agent-go
build-jenkins-agent-go:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-go-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-go-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-go-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-go:$(AMAMBA_IMAGE_VERSION)  \
			--tag $(REGISTRY_REPO)/jenkins-agent-go:latest   \
			-f ./jenkins-agent/go/Dockerfile \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/go

.PHONY: build-jenkins-agent-go-podman
build-jenkins-agent-go-podman:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-go-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-go-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-go-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-go:$(AMAMBA_IMAGE_VERSION)-podman  \
			--tag $(REGISTRY_REPO)/jenkins-agent-go:latest-podman   \
			-f ./jenkins-agent/go/Dockerfile \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/go

.PHONY: build-jenkins-agent-maven-all
build-jenkins-agent-maven-all: build-jenkins-agent-maven build-jenkins-agent-maven-podman

.PHONY: build-jenkins-agent-maven
build-jenkins-agent-maven:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-maven-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-maven-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-maven-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-maven:$(AMAMBA_IMAGE_VERSION)  \
			--tag $(REGISTRY_REPO)/jenkins-agent-maven:latest  \
			-f ./jenkins-agent/maven/Dockerfile \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/maven

.PHONY: build-jenkins-agent-maven-podman
build-jenkins-agent-maven-podman:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-maven-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-maven-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-maven-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-maven:$(AMAMBA_IMAGE_VERSION)-podman  \
			--tag $(REGISTRY_REPO)/jenkins-agent-maven:latest-podman  \
			-f ./jenkins-agent/maven/Dockerfile \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/maven

.PHONY: build-jenkins-agent-nodejs-all
build-jenkins-agent-nodejs-all: build-jenkins-agent-nodejs16 build-jenkins-agent-nodejs16-podman

.PHONY: build-jenkins-agent-nodejs16
build-jenkins-agent-nodejs16:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-nodejs16-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-nodejs16-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-nodejs16-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-nodejs:$(AMAMBA_IMAGE_VERSION)-v16.17.0  \
			--tag $(REGISTRY_REPO)/jenkins-agent-nodejs:latest-v16.17.0  \
			-f ./jenkins-agent/nodejs/Dockerfile \
			--build-arg VERSION=16.17.0 \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/nodejs

.PHONY: build-jenkins-agent-nodejs16-podman
build-jenkins-agent-nodejs16-podman:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-nodejs16-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-nodejs16-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-nodejs16-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-nodejs:$(AMAMBA_IMAGE_VERSION)-v16.17.0-podman  \
			--tag $(REGISTRY_REPO)/jenkins-agent-nodejs:latest-v16.17.0-podman  \
			-f ./jenkins-agent/nodejs/Dockerfile \
			--build-arg VERSION=16.17.0 \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/nodejs

.PHONY: build-jenkins-agent-python-all
build-jenkins-agent-python-all: build-jenkins-agent-python build-jenkins-agent-python-podman

.PHONY: build-jenkins-agent-python
build-jenkins-agent-python:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-python-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-python-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-python-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-python:$(AMAMBA_IMAGE_VERSION)  \
			--tag $(REGISTRY_REPO)/jenkins-agent-python:latest  \
			-f ./jenkins-agent/python/Dockerfile \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/python

.PHONY: build-jenkins-agent-python-podman
build-jenkins-agent-python-podman:
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-python-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-python-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-python-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/jenkins-agent-python:$(AMAMBA_IMAGE_VERSION)-podman  \
			--tag $(REGISTRY_REPO)/jenkins-agent-python:latest-podman  \
			-f ./jenkins-agent/python/Dockerfile \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/python

.PHONY: build-jenkins-agent-all
build-jenkins-agent-all: build-jenkins-agent-base-podman
	make build-jenkins-agent-extend -j4

.PHONY: build-jenkins-agent-extend
build-jenkins-agent-extend: build-jenkins-agent-go-all build-jenkins-agent-maven-all build-jenkins-agent-nodejs-all build-jenkins-agent-python-all

.PHONY: sync-all-jenkins-agent-imgs
sync-all-jenkins-agent-imgs:
	echo ${REGISTRY_PASSWORD} | docker login ${REGISTRY_CI_REPO} -u ${REGISTRY_USERNAME} --password-stdin && \
	echo ${REGISTRY_PASSWORD} | docker login ${REGISTRY_REPO} -u ${REGISTRY_USERNAME} --password-stdin && \
	chmod +x ./hack/sync-imgs.sh && ./hack/sync-imgs.sh $(AMAMBA_IMAGE_VERSION) "./hack/imgs-manifest.list" "release.daocloud.io" "release-ci.daocloud.io"

.PHNOY: build-helper
build-helper: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-build-helper-builder ) && docker buildx create --use --name amamba-jenkins-agent-build-helper-builder ;\
	docker buildx build \
		--builder amamba-jenkins-agent-build-helper-builder \
		--platform linux/amd64 \
		--tag $(REGISTRY_REPO)/build-helper:$(AMAMBA_IMAGE_VERSION) \
		--tag $(REGISTRY_REPO)/build-helper:latest  \
		-f ./build/helper/Dockerfile \
        --push \
        ./build/helper