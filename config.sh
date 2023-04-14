#! /bin/bash

######### MAIN CONFIG ##########
# Setup your application deployment here
################################

# Grab build number is mounted in CI system
if [[ -f /config/.buildenv ]]; then
  source /config/.buildenv
else
  BUILD_NUM=-1
fi

FIN_TAG=sandbox
if [[ ! -z "$FIN_VERSION_OVERRIDE" ]]; then
  echo "Using FIN_VERSION_OVERRIDE: $FIN_VERSION_OVERRIDE"
  echo "  -> GitOps version was: $FIN_TAG"
  FIN_TAG=$FIN_VERSION_OVERRIDE
fi

if [[ -z "$BRANCH_NAME" ]]; then
  UCD_DAMS_DEPLOYMENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
else
  UCD_DAMS_DEPLOYMENT_BRANCH=$BRANCH_NAME
fi

if [[ -z "$TAG_NAME" ]]; then
  UCD_DAMS_DEPLOYMENT_TAG=$(git describe --tags --abbrev=0) || true
else
  UCD_DAMS_DEPLOYMENT_TAG=$TAG_NAME
fi

if [[ -z "$SHORT_SHA" ]]; then
  UCD_DAMS_DEPLOYMENT_SHA=$(git log -1 --pretty=%h)
else
  UCD_DAMS_DEPLOYMENT_SHA=$SHORT_SHA
fi

if [[ "$UCD_DAMS_DEPLOYMENT_BRANCH" == "main" && ! -z "$UCD_DAMS_DEPLOYMENT_TAG" ]]; then
  APP_TAG=$UCD_DAMS_DEPLOYMENT_TAG
else
  APP_TAG=$UCD_DAMS_DEPLOYMENT_BRANCH
fi

# Main version number we are tagging the app with. Always update
# this when you cut a new version of the app!
APP_VERSION=${APP_TAG}.${BUILD_NUM}

if [[ -z $DAMS_REPO_TAG ]]; then
  DAMS_REPO_TAG=$UCD_DAMS_DEPLOYMENT_BRANCH
fi

#### End main config ####


# Repositories
GITHUB_ORG_URL=https://github.com/ucd-library

## Core Server
UCD_DAMS_REPO_NAME=dams
UCD_DAMS_REPO_URL=$GITHUB_ORG_URL/$UCD_DAMS_REPO_NAME

# Fin Server
FIN_SERVER_REPO_NAME=fin
FIN_SERVER_REPO_URL=$GITHUB_ORG_URL/$FIN_SERVER_REPO_NAME

##
# Registery
##

if [[ -z $A6T_REG_HOST ]]; then
  A6T_REG_HOST=gcr.io/ucdlib-pubreg

  # set local-dev tags used by 
  # local development docker-compose file
  if [[ $LOCAL_DEV == 'true' ]]; then
    A6T_REG_HOST=localhost/local-dev
  fi
fi

DOCKER_CACHE_TAG=$UCD_DAMS_DEPLOYMENT_BRANCH

# Docker Images
FCREPO_IMAGE_NAME=$A6T_REG_HOST/fin-fcrepo
POSTGRES_IMAGE_NAME=$A6T_REG_HOST/fin-postgres
LB_IMAGE_NAME=$A6T_REG_HOST/fin-apache-lb
SERVER_IMAGE_NAME=$A6T_REG_HOST/fin-base-service
ELASTIC_SEARCH_IMAGE_NAME=$A6T_REG_HOST/fin-elastic-search
INIT_IMAGE_NAME=$A6T_REG_HOST/fin-init
UCD_DAMS_SERVER_IMAGE_NAME=$A6T_REG_HOST/dams-base-service
IMAGE_UTILS_IMAGE_NAME=$A6T_REG_HOST/dams-image-utils
UCD_DAMS_INIT_IMAGE_NAME=$A6T_REG_HOST/dams-init
KEYCLOAK_IMAGE_NAME=$A6T_REG_HOST/dams-keycloak-dev
IIIF_IMAGE_NAME=$A6T_REG_HOST/dams-iipimage-server

ALL_DOCKER_BUILD_IMAGES=( \
 $UCD_DAMS_SERVER_IMAGE_NAME $IMAGE_UTILS_IMAGE_NAME \
 $INIT_IMAGE_NAME $IIIF_IMAGE_NAME \
)

# Google Cloud
GC_PROJECT_ID=digital-ucdavis-edu
IMAGE_UTILS_CLOUD_RUN_SERVICE_NAME=dams-image-utils-$UCD_DAMS_DEPLOYMENT_BRANCH

# Git
GIT=git
GIT_CLONE="$GIT clone"

ALL_GIT_REPOSITORIES=( \
  $UCD_DAMS_REPO_NAME $FIN_SERVER_REPO_URL \
)

# directory we are going to cache our various git repos at different tags
# if using pull.sh or the directory we will look for repositories (can by symlinks)
# if local development
REPOSITORY_DIR=repositories