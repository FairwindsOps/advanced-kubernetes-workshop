#!/usr/bin/env bash

if [ ! $CLOUD_SHELL ]; then
    printf "\n${bold}You're not running inside Google Cloud Shell! This is not recommended. Exiting.\n\n${normal}"
    return
    exit 1
fi

export GKE_ONE_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-ONE)
export GKE_TWO_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-TWO)

echo "gke-ONE ingress gateway: "
echo "$GKE_ONE_ISTIO_GATEWAY"

echo""

echo "gke-TWO ingress gateway: "
echo "$GKE_TWO_ISTIO_GATEWAY"

echo ""
