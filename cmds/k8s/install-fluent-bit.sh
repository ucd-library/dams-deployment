#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

cork-kube init dev -p dams
export KUBECONFIG=~/.kube/dams-dev-microk8s-config

helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

helm install fluent-bit fluent/fluent-bit -n kube-system -f fluent-bit-values.yaml

# or update
# helm upgrade  fluent-bit fluent/fluent-bit -n kube-system -f fluent-bit-values.yaml