#!/usr/bin/env bash

# ************************************************************************
# ************************************************************************
# 
# To deploy the spring boot application and mysql to a kubernetes cluster.
# 
# Prerequisite: 
# 1. Require an account with https://hub.docker.com/.
# 2. Kubernetes cluster setup via ./eks-cluster-setup.sh
# ************************************************************************
# ************************************************************************

# ************************************************************************
# CONFIGURATION PARAMETERS FOR THE SCRIPT

APPLICATION_ENVIRONMENT="<TODO_APP_ENV>" # dev or staging or prod
APPLICATION_NAMESPACE="<TODO_APP_NAME>-$APPLICATION_ENVIRONMENT"

DB_ROOT_PASSWORD="<TODO_DB_ROOT_PASSWORD>"
DB_USERNAME="<TODO_DB_USERNAME>"
DB_PASWORD="<TODO_DB_PASSWORD>"
DB_INSTANCE="<TODO_DB_INSTANCE>"
DB_DATABASE="<TODO_APP_NAME>_$APPLICATION_ENVIRONMENT"
DB_URL="jdbc:mysql://$DB_INSTANCE:3306/$DB_DATABASE?useSSL=<TODO_USE_SSL>"


DOCKER_USERNAME="<TODO_DOCKER_HUB_USERNAME>"
DOCKER_PASSWORD="<TODO_DOCKER_HUB_PASSWORD>"
DOCKER_EMAIL="<TODO_DOCKER_HUB_EMAIL>"

# ************************************************************************


# ************************************************************************

kubectl create namespace $APPLICATION_NAMESPACE

kubectl --namespace=$APPLICATION_NAMESPACE create secret generic db-root-pass --from-literal=password=$DB_ROOT_PASSWORD

kubectl --namespace=$APPLICATION_NAMESPACE create secret generic db-user-pass --from-literal=username=$DB_USERNAME --from-literal=password=$DB_PASWORD

kubectl --namespace=$APPLICATION_NAMESPACE create secret generic db-url --from-literal=database=$DB_DATABASE --from-literal=url=$DB_URL

kubectl --namespace=$APPLICATION_NAMESPACE create secret docker-registry docker-registry-config --docker-server=docker.io --docker-username=$DOCKER_USERNAME --docker-password=$DOCKER_PASSWORD --docker-email=$DOCKER_EMAIL

kubectl apply -f ops/database/db-persistent-volume.yaml --namespace=$APPLICATION_NAMESPACE
kubectl apply -f ops/database/db-persistent-volume-claim.yaml --namespace=$APPLICATION_NAMESPACE
kubectl apply -f ops/database/db-service.yaml --namespace=$APPLICATION_NAMESPACE
kubectl apply -f ops/database/db-deployment.yaml --namespace=$APPLICATION_NAMESPACE

kubectl apply -f ops/application/app-deployment.yaml --namespace=$APPLICATION_NAMESPACE
kubectl apply -f ops/application/app-service.yaml --namespace=$APPLICATION_NAMESPACE