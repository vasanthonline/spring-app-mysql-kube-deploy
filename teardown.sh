#!/usr/bin/env bash

APPLICATION_ENVIRONMENT="dev"
APPLICATION_NAMESPACE="<TODO_APP_NAME>-$APPLICATION_ENVIRONMENT"

kubectl --namespace=$APPLICATION_NAMESPACE delete secret db-root-pass

kubectl --namespace=$APPLICATION_NAMESPACE delete secret db-user-pass

kubectl --namespace=$APPLICATION_NAMESPACE delete secret db-url

kubectl --namespace=$APPLICATION_NAMESPACE delete secret docker-registry-config

kubectl delete -f ops/database/db-persistent-volume.yaml --namespace=$APPLICATION_NAMESPACE
kubectl delete -f ops/database/db-persistent-volume-claim.yaml --namespace=$APPLICATION_NAMESPACE
kubectl delete -f ops/database/db-service.yaml --namespace=$APPLICATION_NAMESPACE
kubectl delete -f ops/database/db-deployment.yaml --namespace=$APPLICATION_NAMESPACE

kubectl delete -f ops/application/app-deployment.yaml --namespace=$APPLICATION_NAMESPACE
kubectl delete -f ops/application/app-service.yaml --namespace=$APPLICATION_NAMESPACE

kubectl delete namespace $APPLICATION_NAMESPACE