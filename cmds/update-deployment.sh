#! /bin/bash

set -e

ENVIRONMENT=$1
DAMS_VERSION=$2

ALLOWED_ENVIRONMENTS=("dev" "sandbox" "prod")

FIN_REGISTRY="us-west1-docker.pkg.dev/digital-ucdavis-edu/pub"
DAMS_REGISTRY="us-west1-docker.pkg.dev/ucdlib-dams/pub"
DAMS_BUILD_REGISTRY_URL="https://raw.githubusercontent.com/ucd-library/cork-build-registry/refs/heads/main/repositories/dams.json"

if [[ ! " ${ALLOWED_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
  echo "Error: Invalid environment. Allowed environments are: ${ALLOWED_ENVIRONMENTS[@]}"
  echo "Usage: $0 <environment> <version>"
  exit 1
fi

if [[ -z "$DAMS_VERSION" ]]; then
  echo "Usage: $0 <environment> <version>"
  exit 1
fi

edit() {
  ROOT=$1
  RESOURCE_TYPE=$2
  IMAGE=$3
  CONTAINER=$4
  OVERLAY=$5

  if [[  "$OVERLAY" ]]; then
    echo "Updating $ROOT resource=$RESOURCE_TYPE container=$CONTAINER image=$IMAGE overlay=$OVERLAY"
    OVERLAY="-o $OVERLAY"
  else
    echo "Updating $ROOT resource=$RESOURCE_TYPE container=$CONTAINER image=$IMAGE for base"
  fi

  cork-kube edit $OVERLAY \
    -f $RESOURCE_TYPE \
    -e "\$.spec.template.spec.containers[?(@.name==\"$CONTAINER\")].image=$IMAGE" \
    --replace \
    -- kustomize/$ROOT
}


REMOTE_JSON_URL=DAMS_BUILD_REGISTRY_URL
JSON_DATA=$(curl -s $DAMS_BUILD_REGISTRY_URL)

FIN_VERSION=$(echo $JSON_DATA | jq -r ".builds[\"$DAMS_VERSION\"].fin")

if [[ "$FIN_VERSION" == "" ]]; then
  echo "Error: Version $DAMS_VERSION not found in the JSON data."
  exit 1
fi

echo -e "Updating DAMS $ENVIRONMENT to version DAMS: $DAMS_VERSION FIN: $FIN_VERSION\n"

edit collection-import job "$DAMS_REGISTRY/dams-base-service:$DAMS_VERSION" importer 
edit elastic-search statefulset "$FIN_REGISTRY/fin-elastic-search:$FIN_VERSION" elasticsearch $ENVIRONMENT
edit fcrepo statefulset "$FIN_REGISTRY/fin-fcrepo:$FIN_VERSION" service $ENVIRONMENT
edit fin/dbsync deployment "$DAMS_REGISTRY/dams-base-service:$DAMS_VERSION" service $ENVIRONMENT
edit fin/gateway deployment "$DAMS_REGISTRY/dams-base-service:$DAMS_VERSION" service $ENVIRONMENT
edit fin/gcs deployment "$DAMS_REGISTRY/dams-base-service:$DAMS_VERSION" service $ENVIRONMENT
edit fin/init job "$DAMS_REGISTRY/dams-init:$DAMS_VERSION" service $ENVIRONMENT
edit fin/uber deployment "$DAMS_REGISTRY/dams-base-service:$DAMS_VERSION" service $ENVIRONMENT
edit fin/workflow deployment "$DAMS_REGISTRY/dams-base-service:$DAMS_VERSION" service $ENVIRONMENT
edit iiif deployment "$DAMS_REGISTRY/dams-iipimage-server:$DAMS_VERSION" service $ENVIRONMENT
edit pg-rest deployment "$FIN_REGISTRY/fin-pg-rest:$FIN_VERSION" service $ENVIRONMENT
edit postgres statefulset "$FIN_REGISTRY/fin-postgres:$FIN_VERSION" database $ENVIRONMENT
edit ucd-lib-client deployment "$DAMS_REGISTRY/dams-base-service:$DAMS_VERSION" service $ENVIRONMENT

if [[ "$NO_COMMIT" != "true" ]]; then
  echo -e "\nCommitting changes to git"

  git add --all
  git commit -m "Updated $ENVIRONMENT to version $VERSION"
  git pull
  git push

fi

echo -e "\nDone updating deployment $ENVIRONMENT to version $VERSION"

