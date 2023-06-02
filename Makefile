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
REGISTRY_REPO?="release.daocloud.io"
REGISTRY_CI_REPO?="release-ci.daocloud.io"
TAG=$(VERSION)-$(JENKINS_VERSION)
BUILD_ARCH?="linux/amd64,linux/arm64"
AMAMBA_IMAGE_VERSION=$(VERSION)

.PHONY: build-jenkins-all
build-jenkins-all: build-amd64 build-arm64 build-manifest #这个过程不能设为并发,一定要保证build-amd64执行成功之后再执行build-arm64 所以在make的时候不要指定-j 参数

.PHONY: build-amd64
build-amd64: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
    ! ( docker buildx ls | grep amamba-jenkins-amd64-multi-platform-builder ) && docker buildx create --use --platform=linux/amd64 --name amamba-jenkins-amd64-multi-platform-builder ;\
	docker buildx build \
    	   --builder amamba-jenkins-amd64-multi-platform-builder \
    	   --platform linux/amd64 \
    	   --tag $(REGISTRY_REPO)/amamba/jenkins:$(TAG)-amd64  \
    	   -f Dockerfile \
    	   --push \
    	   .

.PHONY: build-arm64
build-arm64: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
    ! ( docker buildx ls | grep amamba-jenkins-arm64-multi-platform-builder ) && docker buildx create --use --platform=linux/arm64 --name amamba-jenkins-arm64-multi-platform-builder ;\
	docker buildx build \
    	   --builder amamba-jenkins-arm64-multi-platform-builder \
    	   --platform linux/arm64 \
    	   --tag $(REGISTRY_REPO)/amamba/jenkins:$(TAG)-arm64  \
    	   --build-arg REGISTRY_REPO=$(REGISTRY_REPO) \
    	   -f ./build/Dockerfile \
    	   --build-arg TAG=$(TAG) \
    	   --push \
    	   .

.PHONY: build-manifest
build-manifest:
	docker manifest create $(REGISTRY_REPO)/amamba/jenkins:$(TAG) $(REGISTRY_REPO)/amamba/jenkins:$(TAG)-amd64 $(REGISTRY_REPO)/amamba/jenkins:$(TAG)-arm64
	docker manifest push $(REGISTRY_REPO)/amamba/jenkins:$(TAG)

.PHONY: docker-login
docker-login:
	@echo "push images to $(REGISTRY_REPO)"
	# REGISTRY_PASSWORD and REGISTRY_USER_NAME is inherited from gitlab
	echo ${REGISTRY_PASSWORD} | docker login ${REGISTRY_REPO} -u ${REGISTRY_USER_NAME} --password-stdin

.PHONY: build-jenkins-agent-base-all
build-jenkins-agent-base-all: build-jenkins-agent-base build-jenkins-agent-base-podman

.PHONY: build-jenkins-agent-base
build-jenkins-agent-base: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-base-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-base-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-base-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-base:$(AMAMBA_IMAGE_VERSION)  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-base:latest  \
			-f ./jenkins-agent/base/Dockerfile \
			--push \
			./jenkins-agent/base

.PHONY: build-jenkins-agent-base-podman
build-jenkins-agent-base-podman: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-base-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-base-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-base-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-base:$(AMAMBA_IMAGE_VERSION)-podman  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-base:latest-podman  \
			-f ./jenkins-agent/base/podman/Dockerfile \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/base

.PHNOY: build-jenkins-agent-go-all
build-jenkins-agent-go-all: build-jenkins-agent-go build-jenkins-agent-go-podman

.PHONY: build-jenkins-agent-go
build-jenkins-agent-go: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-go-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-go-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-go-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-go:$(AMAMBA_IMAGE_VERSION)  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-go:latest   \
			-f ./jenkins-agent/go/Dockerfile \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/go

.PHONY: build-jenkins-agent-go-podman
build-jenkins-agent-go-podman: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-go-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-go-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-go-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-go:$(AMAMBA_IMAGE_VERSION)-podman  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-go:latest-podman   \
			-f ./jenkins-agent/go/Dockerfile \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/go

.PHONY: build-jenkins-agent-maven-all
build-jenkins-agent-maven-all: build-jenkins-agent-maven build-jenkins-agent-maven-podman

.PHONY: build-jenkins-agent-maven
build-jenkins-agent-maven: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-maven-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-maven-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-maven-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-maven:$(AMAMBA_IMAGE_VERSION)  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-maven:latest  \
			-f ./jenkins-agent/maven/Dockerfile \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/maven

.PHONY: build-jenkins-agent-maven-podman
build-jenkins-agent-maven-podman: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-maven-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-maven-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-maven-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-maven:$(AMAMBA_IMAGE_VERSION)-podman  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-maven:latest-podman  \
			-f ./jenkins-agent/maven/Dockerfile \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/maven

.PHONY: build-jenkins-agent-nodejs-all
build-jenkins-agent-nodejs-all: build-jenkins-agent-nodejs16 build-jenkins-agent-nodejs16-podman

.PHONY: build-jenkins-agent-nodejs16
build-jenkins-agent-nodejs16: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-nodejs16-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-nodejs16-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-nodejs16-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-nodejs:$(AMAMBA_IMAGE_VERSION)-v16.17.0  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-nodejs:latest-v16.17.0  \
			-f ./jenkins-agent/nodejs/Dockerfile \
			--build-arg VERSION=v16.17.0 \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/nodejs

.PHONY: build-jenkins-agent-nodejs16-podman
build-jenkins-agent-nodejs16-podman: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-nodejs16-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-nodejs16-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-nodejs16-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-nodejs:$(AMAMBA_IMAGE_VERSION)-v16.17.0-podman  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-nodejs:latest-v16.17.0-podman  \
			-f ./jenkins-agent/nodejs/Dockerfile \
			--build-arg VERSION=v16.17.0 \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/nodejs

.PHONY: build-jenkins-agent-nodejs18
build-jenkins-agent-nodejs18: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-nodejs18-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-nodejs18-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-nodejs18-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-nodejs:$(AMAMBA_IMAGE_VERSION)-v18.12.0  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-nodejs:latest-v18.12.0  \
			-f ./jenkins-agent/nodejs/Dockerfile \
			--build-arg VERSION=v18.12.0 \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/nodejs

.PHONY: build-jenkins-agent-nodejs18-podman
build-jenkins-agent-nodejs18-podman: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-nodejs18-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-nodejs18-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-nodejs18-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-nodejs:$(AMAMBA_IMAGE_VERSION)-v18.12.0-podman  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-nodejs:latest-v18.12.0-podman   \
			-f ./jenkins-agent/nodejs/Dockerfile \
			--build-arg VERSION=v18.12.0 \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/nodejs

.PHONY: build-jenkins-agent-python-all
build-jenkins-agent-python-all: build-jenkins-agent-python build-jenkins-agent-python-podman

.PHONY: build-jenkins-agent-python
build-jenkins-agent-python: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-python-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-python-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-python-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-python:$(AMAMBA_IMAGE_VERSION)  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-python:latest  \
			-f ./jenkins-agent/python/Dockerfile \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/python

.PHONY: build-jenkins-agent-python-podman
build-jenkins-agent-python-podman: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-python-podman-multi-platform-builder ) && docker buildx create --use --platform=$(BUILD_ARCH) --name amamba-jenkins-agent-python-podman-multi-platform-builder ;\
	docker buildx build \
			--builder amamba-jenkins-agent-python-podman-multi-platform-builder \
			--platform $(BUILD_ARCH) \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-python:$(AMAMBA_IMAGE_VERSION)-podman  \
			--tag $(REGISTRY_REPO)/amamba/jenkins-agent/builder-python:latest-podman  \
			-f ./jenkins-agent/python/Dockerfile \
			--build-arg RUNTIME="-podman" \
			--build-arg REGISTRY_REPO="$(REGISTRY_REPO)" \
			--push \
			./jenkins-agent/python

.PHONY: build-jenkins-agent-all
build-jenkins-agent-all: build-jenkins-agent-base build-jenkins-agent-base-podman
	make build-jenkins-agent-extend -j4

.PHONY: build-jenkins-agent-extend
build-jenkins-agent-extend: build-jenkins-agent-go-all build-jenkins-agent-maven-all build-jenkins-agent-nodejs-all build-jenkins-agent-python-all

.PHONY: sync-all-jenkins-agent-imgs
sync-all-jenkins-agent-imgs:
	echo ${REGISTRY_PASSWORD} | docker login ${REGISTRY_CI_REPO} -u ${REGISTRY_USER_NAME} --password-stdin && \
	echo ${REGISTRY_PASSWORD} | docker login ${REGISTRY_REPO} -u ${REGISTRY_USER_NAME} --password-stdin && \
	chmod +x ./hack/sync-imgs.sh && ./hack/sync-imgs.sh $(AMAMBA_IMAGE_VERSION) "./hack/imgs-manifest.list" "release.daocloud.io" "release-ci.daocloud.io"

.PHONY: gen-release-notes
gen-release-notes:
	./hack/release-version.sh

.PHNOY: build-helper
build-helper: docker-login
	export DOCKER_CLI_EXPERIMENTAL=enabled ;\
	! ( docker buildx ls | grep amamba-jenkins-agent-build-helper-builder ) && docker buildx create --use --name amamba-jenkins-agent-build-helper-builder ;\
	docker buildx build \
		--builder amamba-jenkins-agent-build-helper-builder \
		--platform linux/amd64 \
		--tag $(REGISTRY_REPO)/amamba/build-helper:$(AMAMBA_IMAGE_VERSION) \
		--tag $(REGISTRY_REPO)/amamba/build-helper:latest  \
		-f ./build/helper/Dockerfile \
        --push \
        ./build/helper