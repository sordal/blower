Introduction
====

Generated template for blower.

## How to Make This Project

This make process supports the following targets:

* clean - clean up and targets in project
* build - build both the project and Docker image
* run   - run the image you just built

The script supports the following parameters:

* VERSION - version to tag docker image wth, default value is the git hash

This will build the Dockerfile located in the image directory by calling
the **build** target on the Make file located in the image directory first and
 then it will build the docker image.

This tool expects the project to be located in a directory called **image**.

Examples:

    make clean

	  make build

    make desktop

    make prodcution

## Description

**WARNING**: You should NEVER modify the root make file, if you need to make customizations for your project use the Makefile located in __image/Makefile__

Please make sure to define the targets located in in the __image/Makefile__:

    clean: settings
      @printf "\e[1;34m[INFO] [cleaning $(project_name)]\e[00m\n\n"
      @printf "\e[1;34m[WARNING] [cleaning $(project_name)]\e[00m\n\n"

    build: settings
      @printf "\e[1;34m[INFO] [building $(project_name)]\e[00m\n\n"
      @printf "\e[1;34m[WARNING] [building $(project_name)]\e[00m\n\n"

## Supported tags

- latest
