#!/usr/bin/env bash

# ************************************************************************
# ************************************************************************
# 
# To build a docker image of the spring boot maven application and push the image
# to dockerhub. 
# Prerequisite: Require an account with https://hub.docker.com/.
# ************************************************************************
# ************************************************************************


# ************************************************************************
# CONFIGURATION PARAMETERS FOR THE SCRIPT

APPLICATION_NAME="<TODO_APP_NAME>"
APPLICATION_VERSION="<TODO_APP_VERSION>"
APPLICATION_ORGANIZATION="<TODO_ORGANIZATION_NAME>"

DOCKER_USERNAME="<TODO_DOCKER_HUB_USERNAME>"
DOCKER_PASSWORD="<TODO_DOCKER_HUB_PASSWORD>"
DOCKER_EMAIL="<TODO_DOCKER_HUB_EMAIL>"

SPRING_APP_PROFILE="<TODO_APP_PROFILE>" #optional, if a profile is defined in pom.xml

# ************************************************************************


# ************************************************************************

./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=$APPLICATION_ORGANIZATION/$APPLICATION_NAME:$APPLICATION_VERSION -P$SPRING_APP_PROFILE -DskipTests


docker push $APPLICATION_ORGANIZATION/$APPLICATION_NAME:$APPLICATION_VERSION


