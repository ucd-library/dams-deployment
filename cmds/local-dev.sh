#! /bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

source ./config.sh


export K8S_NAMESPACE=dams
export LOCAL_DEV=true

CMD=$1

K8S_BACKEND=${K8S_BACKEND:-docker}
cork-kube init local-dev

if [[ $CMD == "start" || $CMD == "deploy"  ]]; then  

  # deploy all pods
  ./cmds/k8s/deploy-local-dev-pods.sh
elif [[ $CMD == "stop" ]]; then

  kubectl delete statefulsets --all -n $K8S_NAMESPACE
  kubectl delete deployments --all -n $K8S_NAMESPACE
  kubectl delete services --all -n $K8S_NAMESPACE
  kubectl delete jobs --all -n $K8S_NAMESPACE
  
elif [[ $CMD == "build" ]]; then


  # Store fin branch override form local fs
  source ../fin/devops/config.sh
  export FIN_VERSION_OVERRIDE=$FIN_BRANCH_NAME

  source $ROOT_DIR/../config.sh

  # build local fin
  $REPOSITORY_DIR/$FIN_SERVER_REPO_NAME/devops/build-context.sh

  echo "building images"
  ./cmds/build.sh

elif [[ $CMD == "create-dashboard" ]]; then
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

  kubectl create serviceaccount -n kubernetes-dashboard admin-user || true
  kubectl create clusterrolebinding admin-user-cluster-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user || true

  echo "Run 'kubectl edit deployment kubernetes-dashboard -n kubernetes-dashboard'"
  echo "Add the following to the spec.containers.args section:"
  echo "  - --token-ttl=86400"
  echo "To increase the token ttl to 24 hours.  Otherwise the token will expire in 30 minutes.  Frustating!"
  echo ""
  echo "Make sure to run 'kubectl proxy' to access the dashboard"


elif [[ $CMD == "dashboard-token" ]]; then
  kubectl create token -n kubernetes-dashboard --duration=720h admin-user
elif [[ $CMD == "log" ]]; then
  POD=$(kubectl get pods --selector=app=$2 -o json | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | .metadata.name')
  if [[ -z $POD ]]; then
    echo "No running pods found for app $2"
    exit -1
  fi
  kubectl logs $POD -f
elif [[ $CMD == "exec" ]]; then
  POD=$(kubectl get pods --selector=app=$2 --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')
  if [[ -z $POD ]]; then
    echo "No running pods found for app $2"
    exit -1
  fi
  POD_CMD=bash
  if [[ ! -z $3 ]]; then
    POD_CMD=$3
  fi
  echo "executing: kubectl exec -ti $POD -- $POD_CMD"
  kubectl exec -ti $POD -- $POD_CMD
elif [[ $CMD == "create-secrets" ]]; then
  LOCAL_DEV=true ./cmds/k8s/create-secrets.sh local-dev
else
  echo "Unknown command: $CMD.  Commands are 'start', 'stop', 'log', 'exec', 'create-dashboard', 'dashboard-token'"
  exit -1
fi

# kubectl create configmap kubeconfig --from-file=$HOME/.kube/config


