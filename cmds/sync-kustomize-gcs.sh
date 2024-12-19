#! /bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

gcloud config set project ucdlib-dams
gsutil -m rsync -r  kustomize gs://dams-kustomize-templates/