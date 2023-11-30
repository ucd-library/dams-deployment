#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config.sh

UCD_DAMS_REPO_BRANCH=$(git -C $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME rev-parse --abbrev-ref HEAD)
UCD_DAMS_REPO_TAG=$(git -C $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME tag --points-at HEAD)
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
echo    "UCD DAMS - Init         : $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG and :$DOCKER_CACHE_TAG"
echo    "UCD DAMS - IIP Server   : $IIIF_IMAGE_NAME:$APP_TAG and :$DOCKER_CACHE_TAG"
echo    "UCD DAMS - Base Service : $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG and :$DOCKER_CACHE_TAG"
echo -e "UCD DAMS - Image Utils  : $IMAGE_UTILS_IMAGE_NAME:$APP_TAG and :$DOCKER_CACHE_TAG\n"

# UCD DAMS - Init Service
docker build \
  -t $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG \
  --build-arg FIN_INIT=$INIT_IMAGE_NAME:$FIN_TAG \
  --cache-from $UCD_DAMS_INIT_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/init
docker tag $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG $UCD_DAMS_INIT_IMAGE_NAME:$DOCKER_CACHE_TAG

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
docker tag $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG $UCD_DAMS_SERVER_IMAGE_NAME:$DOCKER_CACHE_TAG

# DAMS - Image Utils Service
docker build \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  -t $IMAGE_UTILS_IMAGE_NAME:$APP_TAG \
  --cache-from $IMAGE_UTILS_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/image-utils
docker tag $IMAGE_UTILS_IMAGE_NAME:$APP_TAG $IMAGE_UTILS_IMAGE_NAME:$DOCKER_CACHE_TAG

# DAMS - IIP Server
docker build \
  -t $IIIF_IMAGE_NAME:$APP_TAG \
  --cache-from $IIIF_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/iipimage
docker tag $IIIF_IMAGE_NAME:$APP_TAG $IIIF_IMAGE_NAME:$DOCKER_CACHE_TAG
