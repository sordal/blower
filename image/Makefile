ifdef VERSION
	project_version:=$(VERSION)
else
	project_version:=$(shell git rev-parse --short=8 HEAD)
endif

ifdef PROJECT_NAME
	project_name:=$(PROJECT_NAME)
else
	project_name:=$(shell git config --local remote.origin.url | sed -n 's\#.*/\(.*\)\.git\#\1\#p')
endif

ifdef SRC_DIR
	source_directory:=$(SRC_DIR)
else
	source_directory:=$(CURDIR)
endif

version:
	@printf "\e[1;34m[INFO] [version]\e[00m\n\n"
	@echo [INFO] Project Makefile Version 2.0:
	@echo

settings: version
	@printf "\e[1;34m[INFO] [settings]\e[00m\n\n"
	@echo [INFO] 	project_version=$(project_version)
	@echo [INFO] 	project_name=$(project_name)
	@echo [INFO] 	source_directory=$(source_directory)
	@echo

help: settings
	@printf "\e[1;34m[INFO] [information]\e[00m\n\n"
	@echo [INFO] This make process supports the following targets:
	@echo [INFO]    clean     - Clean up and targets in project
	@echo [INFO]    build     - Build both the project and Docker image
	@echo
	@echo [INFO] The script supports the following parameters:
	@echo [INFO] 	VERSION - version to tag docker image wth, default value is the git hash
	@echo [INFO] 	PROJECT_NAME - project name, default is git project name
	@echo
	@echo [INFO] This will build the  project.
	@echo
	@echo [INFO] Examples:
	@echo
	@echo [INFO]	make build
	@echo
	@echo [INFO]	make build VERSION=666 PROJECT_NAME=dark_place
	@echo

clean: settings
	@printf "\e[1;34m[INFO] [cleaning $(project_name)]\e[00m\n\n"

build: settings
	@printf "\e[1;34m[INFO] [building $(project_name)]\e[00m\n\n"
	cd $(source_directory)/app; pip3 install -r requirements.txt
	cd $(source_directory)/app; python3 build_version.py --version=$(project_name)-$(project_version)

