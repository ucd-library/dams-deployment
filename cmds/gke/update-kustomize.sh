#! /bin/bash

FIN_REPO=https://github.com/ucd-library/fin.git
TMP_DIR=fin-tmp
FIN_DEPLOYMENT_TEMPLATE=./kustomize/templates/fin/deployment.yaml
FIN_KUSTOMIZE_FILE=./kustomize/templates/fin/kustomization.yaml
TEMPLATE_ROOT=./kustomize/fin

LATEST_TAG=$(git describe --tags --abbrev=0)
DEV_TAG=dev
SANDBOX_TAG=sandbox
LOCAL_DEV_TAG=$(git rev-parse --abbrev-ref HEAD)

# if [[ -z "$1" ]]; then
#   echo "No fin tag or branch provided, exiting"
#   exit -1;
# fi

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../../config.sh

for file in "$TEMPLATE_ROOT"/*; do
  if [[ -d $file ]]; then
    basename=$(basename "$file")
    if [[ $basename == .* ]]; then
      continue
    fi

    if [[ $file == "$TEMPLATE_ROOT/base" ]]; then
      continue
    fi
    echo "Updating deployment $file"

    cat $root/$FILE | \
      yq eval ".spec.template.spec.containers[0].image = \"${IMAGE}:${LATEST_TAG}\"" 
      > $root/$FILE
    # cp $FIN_KUSTOMIZE_FILE $root/kustomization.yaml

    # root=$file/overlays/dev
    # mkdir -p $root
    # cat $FIN_DEPLOYMENT_TEMPLATE | \
    #   yq eval ".spec.template.spec.containers[0].image = \"${IMAGE}:${DEV_TAG}\"" | \
    #   yq eval ".metadata.name = \"$basename\"" \
    #   > $root/$FILE
    # cp $FIN_KUSTOMIZE_FILE $root/kustomization.yaml

    # root=$file/overlays/sandbox
    # mkdir -p $root
    # cat $FIN_DEPLOYMENT_TEMPLATE | \
    #   yq eval ".spec.template.spec.containers[0].image = \"${IMAGE}:${SANDBOX_TAG}\"" | \
    #   yq eval ".metadata.name = \"$basename\"" \
    #   > $root/$FILE
    # cp $FIN_KUSTOMIZE_FILE $root/kustomization.yaml

    # root=$file/overlays/local-dev
    # mkdir -p $root
    # cat $FIN_DEPLOYMENT_TEMPLATE | \
    #   yq eval ".spec.template.spec.containers[0].image = \"${LOCAL_DEV_BASE}/${IMAGE_ROOT}:${LOCAL_DEV_TAG}\"" | \
    #   yq eval ".metadata.name = \"$basename\"" \
    #   > $root/$FILE
    # cp $FIN_KUSTOMIZE_FILE $root/kustomization.yaml
 
  fi
done

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