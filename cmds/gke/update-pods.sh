#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

./setup-kubectl.sh

# core services
kubectl apply -k ./kustomize/elastic-search/base
kubectl apply -k ./kustomize/postgres
kubectl apply -k ./kustomize/fcrepo
kubectl apply -k ./kustomize/rabbitmq
kubectl apply -k ./kustomize/redis

# fin services
kubectl apply -k ./kustomize/fin/gateway
kubectl apply -k ./kustomize/fin/dbsync
kubectl apply -k ./kustomize/fin/init
kubectl apply -k ./kustomize/fin/uber