#!/bin/bash

if [ ! $CLOUD_SHELL ]; then
    printf "\n${bold}You're not running inside Google Cloud Shell! This is not recommended. Exiting.\n\n${normal}"
    return
    exit 1
fi

kubectl exec -it $(kubectl get pod --context gke-spinnaker | grep fortio | awk '{ print $1 }') --context gke-spinnaker -c fortio -- fortio load -c 50 -qps 1000 -t $1 $2
