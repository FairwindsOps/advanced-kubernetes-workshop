#!/bin/bash

# Get the demo magic
. .demo-magic.sh
clear

# Check clusters exist

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

printf "\n${bold}*** Lab 0: Setup Walk Through ***${normal}\n"
wait

# Check kubectx
printf "\n${bold}Check clusters exist${normal}\n"
pe kubectx

# Check Istio installation
printf "\n${bold}Check Istio is installed on GKE-West cluster${normal}\n"
pe "kubectl get deployments -n istio-system --context gke-west"

printf "\n${bold}Check Istio is installed on GKE-Central cluster${normal}\n"
pe "kubectl get deployments -n istio-system --context gke-central"
wait

# Check Spinnaker Installation
printf "\n${bold}Check Spinnaker is installed on GKE-Spinnaker cluster${normal}\n"
pe "kubectl get deployments --context gke-spinnaker"
wait

# Check ISTIO-INJECTION is enabled on GKE-West and GKE_Central
printf "\n${bold}Check ISTIO-INJECTION is enabled on GKE-Central cluster${normal}\n"
pe "kubectl get namespace -L istio-injection --context gke-central"

printf "\n${bold}Check ISTIO-INJECTION is enabled on GKE-West cluster${normal}\n"
pe "kubectl get namespace -L istio-injection --context gke-west"
wait

# Check appliation is installed on all three namespaces on both GKE-West and GKE-Central clusters
printf "\n${bold}Check Application is installed on GKE-Central cluster in production, staging and dev namespaces${normal}\n"
pe "kubectl get all -n production --context gke-central"
wait
pe "kubectl get all -n staging --context gke-central"
wait
pe "kubectl get all -n dev --context gke-central"
wait

printf "\n${bold}Check Application is installed on GKE-West cluster in production, staging and dev namespaces${normal}\n"
pe "kubectl get all -n production --context gke-west"
wait
pe "kubectl get all -n staging --context gke-west"
wait
pe "kubectl get all -n dev --context gke-west"
wait

# Check GCR Images
printf "\n${bold}Check container images in Container Registry (GCR.io)${normal}\n"
wait
pe "gcloud container images list"
wait

# Check GCS Manifests
printf "\n${bold}Check Kubernetes manifests or YAML files in Cloud Storage bucket (GCS)${normal}\n"
wait
export PROJECT=$(gcloud info --format='value(config.project)')
pe "gsutil ls gs://$PROJECT-spinnaker/manifests"
wait

# Check PubSub Topics
printf "\n${bold}Check Cloud PubSub topics i.e. for publishers (the pub in pubsub)${normal}\n"
wait
pe "gcloud pubsub topics list"
wait

# Check PubSub Subscriptions
printf "\n${bold}Check Cloud PubSub subscriptions i.e. for subscribers (the sub in pubsub)${normal}\n"
wait
pe "gcloud pubsub subscriptions list"
wait

# Run connect.sh script
printf "\n${bold}Open ports to Spinnaker, Grafana, Prometheus, Jaeger and ServiceGraph${normal}\n"
wait
pe workshop_connect
