#! /bin/bash

FIN_REPO=https://github.com/ucd-library/fin.git
TMP_DIR=fin-tmp

if [[ -z "$1" ]]; then
  echo "No fin tag or branch provided, exiting"
  exit -1;
fi

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

if [[ -d $TMP_DIR ]]; then
  rm -rf $TMP_DIR
fi

echo "Pulling kustomize templates from fin repo @ $1"
git clone $FIN_REPO \
  --branch $1 \
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