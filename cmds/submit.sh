#! /bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

gcloud config set project digital-ucdavis-edu

# environment 
if [[ -z $ENV ]]; then
  ENV=$1
fi
if [[ -z $ENV ]]; then
  echo "ENV not set"
  exit 1
fi

TAG_NAME=$(git describe --tags --abbrev=0)
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
SHORT_SHA=$(git log -1 --pretty=%h)

echo "Submitting build to Google Cloud..."
gcloud builds submit \
  --config ./gcloud/cloudbuild.yaml \
  --substitutions=REPO_NAME=dams-deployment,_ENV=${ENV},TAG_NAME=${TAG_NAME},BRANCH_NAME=${BRANCH_NAME},SHORT_SHA=${SHORT_SHA} \
  .