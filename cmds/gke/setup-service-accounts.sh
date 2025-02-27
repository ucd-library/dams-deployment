#! /bin/bash
# https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/cloud-storage-fuse-csi-driver

# set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../../config/load.sh $1

cork-kube init $1 -c ../..

echo "This script expects the following bucket and google cloud service acount to exist:"
echo "Bucket: ${GCS_BUCKET}"
echo "Service Account: ${GC_SA_NAME}"

kubectl create serviceaccount ${GKE_KSA_NAME} \
    --namespace default

# gcloud iam service-accounts create $GC_SA_NAME \
#     --project=${GC_PROJECT_ID}
echo "1"
gcloud storage buckets add-iam-policy-binding gs://${GCS_BUCKET} \
    --member "serviceAccount:$GC_SA_NAME" \
    --role "roles/storage.objectAdmin"

echo "2"
gcloud iam service-accounts add-iam-policy-binding $GC_SA_NAME \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$GC_PROJECT_ID.svc.id.goog[default/$GKE_KSA_NAME]"

echo "3"
kubectl annotate serviceaccount ${GKE_KSA_NAME} \
    --namespace default \
    iam.gke.io/gcp-service-account=$GC_SA_NAME