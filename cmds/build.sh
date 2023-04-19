#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config.sh

UCD_DAMS_REPO_BRANCH=$(git -C $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME rev-parse --abbrev-ref HEAD)
UCD_DAMS_REPO_TAG=$(git -C $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME describe --tags --abbrev=0) || true
UCD_DAMS_REPO_SHA=$(git -C $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME log -1 --pretty=%h)

echo -e "Starting docker build\n"

echo "DAMS Repository:"
echo "Branch: $UCD_DAMS_REPO_BRANCH"
echo "Tag: $UCD_DAMS_REPO_TAG"
echo -e "SHA: $UCD_DAMS_REPO_SHA\n"

echo "DAMS Deployment Repository:"
echo "Branch: $UCD_DAMS_DEPLOYMENT_BRANCH"
echo "Tag: $UCD_DAMS_DEPLOYMENT_TAG"
echo -e "SHA: $UCD_DAMS_DEPLOYMENT_SHA\n"

echo "Using base Fin images:"
echo    "Fin - Init              : $INIT_IMAGE_NAME:$FIN_TAG"
echo    "Fin - Fcrepo            : $FCREPO_IMAGE_NAME:$FIN_TAG"
echo    "Fin - Base Service      : $SERVER_IMAGE_NAME:$FIN_TAG"
echo -e "\nBuilding images:"
echo    "UCD DAMS - Init         : $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG"
echo    "UCD DAMS - Fcrepo       : $DAMS_FCREPO_IMAGE_NAME:$APP_TAG"
echo    "UCD DAMS - IIP Server   : $IIIF_IMAGE_NAME:$APP_TAG"
echo    "UCD DAMS - Base Service : $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG"
echo -e "UCD DAMS - Image Utils  : $IMAGE_UTILS_IMAGE_NAME:$APP_TAG\n"

# UCD DAMS - Init Service
docker build \
  -t $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG \
  --build-arg INIT_BASE=$INIT_IMAGE_NAME:$FIN_TAG \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  --cache-from $UCD_DAMS_INIT_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/init

# UCD DAMS - Fcrepo
docker build \
  -t $DAMS_FCREPO_IMAGE_NAME:$APP_TAG \
  --build-arg FIN_FCREPO_BASE_IMAGE=$FCREPO_IMAGE_NAME:$FIN_TAG \
  --cache-from $DAMS_FCREPO_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/fcrepo

# UCD DAMS - Main service image
docker build \
  --build-arg APP_VERSION=$APP_VERSION \
  --build-arg BUILD_NUM=${BUILD_NUM} \
  --build-arg UCD_DAMS_REPO_BRANCH=${UCD_DAMS_REPO_BRANCH} \
  --build-arg UCD_DAMS_REPO_TAG=${UCD_DAMS_REPO_TAG} \
  --build-arg UCD_DAMS_REPO_SHA=${UCD_DAMS_REPO_SHA} \
  --build-arg UCD_DAMS_DEPLOYMENT_SHA=${UCD_DAMS_DEPLOYMENT_SHA} \
  --build-arg UCD_DAMS_DEPLOYMENT_BRANCH=${UCD_DAMS_DEPLOYMENT_BRANCH} \
  --build-arg UCD_DAMS_DEPLOYMENT_TAG=${UCD_DAMS_DEPLOYMENT_TAG} \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  -t $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG \
  --cache-from $UCD_DAMS_SERVER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -f $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/fin/Dockerfile \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME

# DAMS - Image Utils Service
docker build \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  -t $IMAGE_UTILS_IMAGE_NAME:$APP_TAG \
  --cache-from $IMAGE_UTILS_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/image-utils

# DAMS - IIP Server
docker build \
  -t $IIIF_IMAGE_NAME:$APP_TAG \
  --cache-from $IIIF_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/iipimage
