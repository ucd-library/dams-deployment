#! /bin/bash

# docs
# https://cloud.google.com/kubernetes-engine/docs/tutorials/autoscaling-metrics?_gl=1*hy7l8b*_ga*MTczMDI5MjAzNi4xNjQ4NDgzNDkw*_ga_WH2QY8WWF5*MTcxNTEwMzUyNy4zNTAuMS4xNzE1MTA1OTk4LjAuMC4w#custom-metric
# https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/custom-metrics-stackdriver-adapter

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../../config.sh

cork-kube init sandbox

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)

kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/k8s-stackdriver/master/custom-metrics-stackdriver-adapter/deploy/production/adapter_new_resource_model.yaml


gcloud iam service-accounts add-iam-policy-binding --role \
  roles/iam.workloadIdentityUser --member \
  "serviceAccount:$GC_PROJECT_ID.svc.id.goog[custom-metrics/custom-metrics-stackdriver-adapter]" \
  $GC_SA_NAME

kubectl annotate serviceaccount --namespace custom-metrics \
  custom-metrics-stackdriver-adapter \
  iam.gke.io/gcp-service-account=$GC_SA_NAME

kubectl annotate serviceaccount --namespace custom-metrics \
  custom-metrics-stackdriver-adapter \
  iam.gke.io/gcp-service-account=dams-production@ucdlib-dams.iam.gserviceaccount.com