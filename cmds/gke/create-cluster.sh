#! /bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../../config/load.sh $1

gcloud config set project ${GC_PROJECT_ID}

# Create cluster with default pool
gcloud beta container clusters create ${GKE_CLUSTER_NAME} \
  --zone ${GKE_CLUSTER_ZONE} \
  --addons GcsFuseCsiDriver \
  --addons GcePersistentDiskCsiDriver \
  --num-nodes 3 \
  --disk-size 100GB \
  --release-channel=regular \
  --machine-type n4-standard-4 \
  --workload-pool=${GC_PROJECT_ID}.svc.id.goog \
  --node-labels=intendedfor=services



gcloud beta container clusters create dams-prod-v2 \
  --zone us-west1-a \
  --addons GcsFuseCsiDriver \
  --addons GcePersistentDiskCsiDriver \
  --num-nodes 3 \
  --disk-size 100GB \
  --release-channel=regular \
  --machine-type n2-standard-4 \
  --workload-pool=ucdlib-dams.svc.id.goog \
  --node-labels=intendedfor=services

gcloud beta container node-pools create scalable-pool \
  --cluster ${GKE_CLUSTER_NAME} \
  --zone ${GKE_CLUSTER_ZONE} \
  --machine-type e2-standard-4 \
  --num-nodes 1 \
  --disk-size 50GB \
  --workload-metadata=GKE_METADATA \
  --node-labels=intendedfor=scalable-pool \
  --enable-autoscaling --min-nodes 1 --max-nodes 6

gcloud beta container node-pools create scalable-pool \
  --cluster dams-prod-v2 \
  --zone us-west1-a \
  --machine-type n2-standard-4 \
  --num-nodes 1 \
  --disk-size 100GB \
  --workload-metadata=GKE_METADATA \
  --node-labels=intendedfor=scalable-pool \
  --enable-autoscaling --min-nodes 1 --max-nodes 6


# ./create-secrets.sh

# ./setup-service-accounts.sh

# ./create-volumes.sh
