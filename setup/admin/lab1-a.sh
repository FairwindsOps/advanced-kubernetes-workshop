#!/bin/bash

# Get the demo magic
. .demo-magic.sh
clear

# Lab 1 Cloud Shell #1

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

printf "\n${bold}*** Lab 1: Build Walk Through - Cloud Shell Window #1 ***${normal}\n"
wait

printf "\n${bold}Check current dev namespace deployments${normal}\n"
pe "kubectl get all -n dev --context gke-central"
wait

# Inspect files for frontend
printf "\n${bold}Inspect frontend app files${normal}\n"
pe "cd ~/advanced-kubernetes-workshop/services/frontend/; ls -al"
wait

# Inspect Dockerfile
printf "\n${bold}Inspect frontend Dockerfile${normal}\n"
pe "cat Dockerfile"
wait

# Inspect skaffold.yaml
printf "\n${bold}Inspect skaffold.yaml${normal}\n"
pe "cat skaffold.yaml"
wait

# Inspect frontend dev manifest file
printf "\n${bold}Inspect frontend dev manifest file${normal}\n"
pe "cat k8s-frontend-dev.yml"

# Start skaffold dev
printf "\n${bold}Start skaffold dev${normal}\n"
pe "cd ~/advanced-kubernetes-workshop/services/frontend/"
pe "kubectx gke-central"
pe "kubectl config set-context $(kubectl config current-context) --namespace=dev"
pe "skaffold dev"
