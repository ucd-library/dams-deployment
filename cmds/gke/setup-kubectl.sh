#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../../config.sh

CURRENT_PROJECT=$(gcloud config get project)
if [[ $GC_PROJECT_ID != $CURRENT_PROJECT ]]; then
  gcloud config set project $GC_PROJECT_ID
fi

K8S_USER=$(kubectl auth whoami -o=jsonpath="{.status.userInfo.username}")
GCLOUD_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
CURRENT_CONTEXT=$(kubectl config current-context)
if [[ $CURRENT_CONTEXT != $GKE_KUBECTL_CONTEXT || $GCLOUD_USER != $K8S_USER ]]; then
  gcloud container clusters get-credentials $GKE_CLUSTER_NAME \
    --zone=$GKE_CLUSTER_ZONE \
    --project=$GC_PROJECT_ID
fi

