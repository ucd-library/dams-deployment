#! /bin/bash

# set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $ROOT_DIR/../config.sh

ENV=$1
if [[ -z "$ENV" && $LOCAL_DEV == "true" ]]; then
  ENV="local-dev"
fi
if [[ -z "$ENV" ]]; then
  echo "No environment provided, exiting"
  exit -1;
fi

CURRENT_PROJECT=$(gcloud config get project)
CURRENT_CONTEXT=$(kubectl config current-context)

if [[ $GC_PROJECT_ID != $CURRENT_PROJECT ]]; then
  gcloud config set project $GC_PROJECT_ID
fi

if [[ $LOCAL_DEV == "true" || $ENV == "local-dev" ]]; then
  if [[ $CURRENT_CONTEXT != "docker-desktop" ]]; then
    kubectl config use-context docker-desktop
  fi
  kubectl config set-context --current --namespace=$K8S_NAMESPACE
else
  K8S_USER=$(kubectl auth whoami -o=jsonpath="{.status.userInfo.username}")
  GCLOUD_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
  kubectl config set-context --current --namespace=default
  if [[ $CURRENT_CONTEXT != $GKE_KUBECTL_CONTEXT || $GCLOUD_USER != $K8S_USER ]]; then
    gcloud container clusters get-credentials $GKE_CLUSTER_NAME \
      --zone=$GKE_CLUSTER_ZONE \
      --project=$GC_PROJECT_ID
  fi
fi

CURRENT_PROJECT=$(gcloud config get project)
CURRENT_CONTEXT=$(kubectl config current-context)
echo "current gcloud project: $CURRENT_PROJECT"
echo "current kubectl context: $CURRENT_CONTEXT"
echo "current kubectl namespace: $(kubectl config view --minify --output 'jsonpath={..namespace}')"