#! /bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

source ./config.sh


export K8S_NAMESPACE=dams
export LOCAL_DEV=true

CMD=$1

K8S_BACKEND=${K8S_BACKEND:-docker}

if [[ $CMD == "start" || $CMD == "deploy"  ]]; then  

  cork-kube up local-dev

elif [[ $CMD == "stop" ]]; then

  cork-kube stop local-dev
  
elif [[ $CMD == "build" ]]; then


  # Store fin branch override form local fs
  source ../fin/devops/config.sh
  export FIN_VERSION_OVERRIDE=$FIN_BRANCH_NAME

  source $ROOT_DIR/../config.sh

  # build local fin
  $REPOSITORY_DIR/$FIN_SERVER_REPO_NAME/devops/build-context.sh

  echo "building images"
  ./cmds/build.sh

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
else
  echo "Unknown command: $CMD.  Commands are 'start', 'stop', 'log', 'exec', 'create-dashboard', 'dashboard-token'"
  exit -1
fi

# kubectl create configmap kubeconfig --from-file=$HOME/.kube/config


