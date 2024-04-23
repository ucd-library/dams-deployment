#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

./setup-kubectl.sh

# core services
kubectl apply -k ./kustomize/elastic-search/base
kubectl apply -k ./kustomize/postgres/base
kubectl apply -k ./kustomize/fcrepo/base
kubectl apply -k ./kustomize/rabbitmq/base
kubectl apply -k ./kustomize/redis/base

# fin services
kubectl apply -k ./kustomize/fin/gateway/base
kubectl apply -k ./kustomize/fin/dbsync/base
kubectl apply -k ./kustomize/fin/init/overlays/prod
kubectl apply -k ./kustomize/fin/uber/base