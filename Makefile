ifdef VERSION
	project_version:=$(VERSION)
else
	project_version:=$(shell git rev-parse --short=8 HEAD)
endif

ifdef PROJECT_NAME
	project_name:=$(PROJECT_NAME)
else
	project_name:=$(shell basename $(CURDIR))
endif

ifdef SRC_DIR
	source_directory:=$(SRC_DIR)
else
	source_directory:=$(CURDIR)/image
endif

ifdef CLUSTER_NAME
	cluster_name:=$(CLUSTER_NAME)
else
	cluster_name:=applegate-$(project_name)
endif

ifdef GCLOUD_PATH
	gcloud_cmd:=$(GCLOUD_PATH)/gcloud
else
	gcloud_cmd:=gcloud
endif

repository:=gcr.io/applegate-road-2829/$(project_name)
latest_image:=$(repository):latest
version_image:=$(repository):$(project_version)
docker_machine_ip:=$(shell bash docker-ip.sh)

gcloud_docker_cmd:=$(gcloud_cmd) docker

gcloud_config:
	$(gcloud_cmd) config set project applegate-road-2829

version:
	@echo [INFO] [version]
	@echo [INFO]    Build Makefile Version 1.31
	@echo

settings: version
	@echo [INFO] [settings]
	@echo [INFO]    project_version=$(project_version)
	@echo [INFO]    project_name=$(project_name)
	@echo [INFO]    repository=$(repository)
	@echo [INFO]    latest_image=$(latest_image)
	@echo [INFO]    version_image=$(version_image)
	@echo [INFO]    source_directory=$(source_directory)
	@echo [INFO]    cluster_name=$(cluster_name)
	@echo [INFO]    docker_machine_ip=$(docker_machine_ip)
	@echo

help: settings
	@printf "\e[1;34m[INFO] [information]\e[00m\n\n"
	@echo [INFO] This make process supports the following targets:
	@echo [INFO]    clean       - clean up and targets in project
	@echo [INFO]    build       - build both the project and Docker image
	@echo [INFO]    push        - push image to repository
	@echo [INFO]    deploy      - push image to cloud
	@echo [INFO]    destroy     - destroy cloud cluster
	@echo [INFO]    production  - run the service locally in production mode
	@echo [INFO]    desktop     - run the service locally in desktop/development mode
	@echo
	@echo [INFO] The script supports the following parameters:
	@echo [INFO]    VERSION      - version to tag docker image wth, default value is the git hash
	@echo [INFO]    PROJECT_NAME - project name, default is git project name
	@echo [INFO]    SRC_DIR      - source code, default is "image"
	@echo [INFO]    CLUSTER_NAME - cluster name, default is "project_name-cluster-1"
	@echo
	@echo [INFO] This tool expects the project to be located in a directory called image.
	@echo [INFO] If there is a Makefile in the image directory, then this tool will execute it
	@echo [INFO] with either clean and build targets.
	@echo
	@echo [INFO] Handy command to run this docker image:
	@echo [INFO]
	@echo [INFO] Run in interactive mode:
	@echo [INFO]
	@echo [INFO]     docker run -t -i  $(version_image)
	@echo [INFO]
	@echo [INFO] Run as service with ports in interactive mode:
	@echo [INFO]
	@echo [INFO]     make desktop
	@echo [INFO]     make production


build_source_directory:
ifneq ("$(wildcard $(source_directory)/Makefile)","")
	@echo [DEBUG] Found Makefile
	$(MAKE) -C $(source_directory) build VERSION=$(project_version) PROJECT_NAME=$(project_name) SRC_DIR=$(source_directory)
endif

build_docker:
	docker build --rm --build-arg PROJECT_VERSION=$(project_version) --build-arg PROJECT_NAME=$(project_name) --tag $(version_image) $(source_directory)
	docker tag $(version_image) $(latest_image)

	@echo [INFO] Handy command to run this docker image:
	@echo [INFO]
	@echo [INFO] Run in interactive mode:
	@echo [INFO]
	@echo [INFO]     docker run -t -i  $(version_image)
	@echo [INFO]
	@echo [INFO] Run as service with ports in interactive mode:
	@echo [INFO]
	@echo [INFO]     make desktop
	@echo [INFO]     make production

build: settings build_source_directory build_docker

clean: settings
ifneq ("$(wildcard $(source_directory)/Makefile)","")
	$(MAKE) -C $(source_directory) clean VERSION=$(project_version) PROJECT_NAME=$(project_name) SRC_DIR=$(source_directory)
endif
	export DOCKER_IP=$(docker_machine_ip);cd $(CURDIR)/env/desktop;docker-compose rm -f
	export DOCKER_IP=$(docker_machine_ip);cd $(CURDIR)/env/production;docker-compose rm -f
	docker images | grep '<none>' | awk '{system("docker rmi -f " $$3)}'
	docker images | grep '$(repository)' | awk '{system("docker rmi -f " $$3)}'

push_source_directory:
ifneq ("$(wildcard $(source_directory)/Makefile)","")
	$(MAKE) -C $(source_directory) push VERSION=$(project_version) PROJECT_NAME=$(project_name) SRC_DIR=$(source_directory)
endif

push: gcloud_config settings push_source_directory build_docker
	docker tag  $(version_image) $(latest_image)
	$(gcloud_docker_cmd) -- push $(version_image)
	$(gcloud_docker_cmd) -- push $(latest_image)

production: settings
	export DOCKER_IP=$(docker_machine_ip);cd $(CURDIR)/env/production;docker-compose up -d

desktop: settings
	export DOCKER_IP=$(docker_machine_ip);cd $(CURDIR)/env/desktop;docker-compose up

connect: settings
	$(gcloud_cmd) compute --project "applegate-road-2829" ssh --zone "us-central1-b" "build-machine"

stop: settings
	export DOCKER_IP=$(docker_machine_ip);cd $(CURDIR)/env/production;docker-compose stop
	export DOCKER_IP=$(docker_machine_ip);cd $(CURDIR)/env/desktop;docker-compose stop
