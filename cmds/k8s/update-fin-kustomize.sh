#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../../config/load.sh $1

FIN_REPO=https://github.com/ucd-library/fin.git
TMP_DIR=fin-tmp

LATEST_TAG=$(git describe --tags --abbrev=0)
LOCAL_DEV_TAG=$(git rev-parse --abbrev-ref HEAD)

if [[ -z "$1" ]]; then
  echo "No branch provided, exiting"
  exit -1;
fi

if [[ ! -z "$2" ]]; then
  LATEST_TAG=$2
fi
BRANCH=$1


if [[ -d $TMP_DIR ]]; then
  rm -rf $TMP_DIR
fi

echo "Pulling kustomize templates from fin repo @ $FIN_TAG"
git clone $FIN_REPO \
  --branch $FIN_TAG \
  --depth 1 \
  --single-branch \
  $TMP_DIR

if [[ ! -d ./kustomize ]]; then
  mkdir ./kustomize
fi

cp -r $TMP_DIR/devops/k8s-kustomize/* ./kustomize

cd $TMP_DIR
HASH=$(git log -1 --pretty=%h)
cd ..

DATETIME=$(date "+%Y-%m-%dT%H:%M:%S%z")
echo "Updated base fin kustomize templates from $FIN_REPO @ $1 ($HASH) on $DATETIME" > ./kustomize/fin-templates.md


rm -rf $TMP_DIR