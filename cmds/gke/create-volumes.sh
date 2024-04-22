#! /bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../../config.sh
./setup-kubectl.sh

kubectl apply -k ./kustomize/ocfl-volume/overlays/prod
