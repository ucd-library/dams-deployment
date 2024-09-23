#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/../..

SECRET_DIR=$(pwd)/secrets
if [[ ! -d $SECRET_DIR ]]; then
  mkdir $SECRET_DIR
fi

./cmds/setup-gcloud-kubectl.sh $1
source ./config.sh


if [[ $LOCAL_DEV == "true" ]]; then
  gcloud secrets versions access latest --secret=local-dev-env > $SECRET_DIR/env
  gcloud secrets versions access latest --secret=local-dev-service-account > $SECRET_DIR/service-account.json

  # adding local kubeconfig as configmap for mounting
  cp $HOME/.kube/config $SECRET_DIR/kubeconfig
  yq eval '(.clusters[] | select(.name == "docker-desktop") | .cluster.server ) = "https://kubernetes.docker.internal:6443" | .'  $SECRET_DIR/kubeconfig > $SECRET_DIR/kubeconfig.tmp && \
    mv $SECRET_DIR/kubeconfig.tmp $SECRET_DIR/kubeconfig

  # make sure the dams service account has cluster-admin role
  kubectl create clusterrolebinding dams-cluster-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=dams:default || true

  kubectl delete configmap kubeconfig -n $K8S_NAMESPACE || true
  kubectl create configmap kubeconfig --from-file=$SECRET_DIR/kubeconfig -n $K8S_NAMESPACE || trues

else
  gcloud secrets versions access latest --secret=production-env > $SECRET_DIR/env
  gcloud secrets versions access latest --secret=production-service-account > $SECRET_DIR/service-account.json
fi

kubectl delete secret env-config || true
kubectl create secret generic env-config \
  --from-file=.env=$SECRET_DIR/env

kubectl delete secret service-account || true
kubectl create secret generic service-account \
 --from-file=service-account.json=$SECRET_DIR/service-account.json || true

# Set up SSL cert secrets
if [[ $LOCAL_DEV != "true" ]]; then
  gcloud secrets versions access latest --secret=dams-ssl-cert > $SECRET_DIR/dams-ssl.crt
  gcloud secrets versions access latest --secret=dams-ssl-key > $SECRET_DIR/dams-ssl.key

  kubectl delete secret dams-ssl || true
  kubectl create secret generic dams-ssl \
  --from-file=dams-ssl.crt=$SECRET_DIR/dams-ssl.crt \
  --from-file=dams-ssl.key=$SECRET_DIR/dams-ssl.key || true
fi
