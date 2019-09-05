#!/bin/bash

# Get the demo magic
. .demo-magic.sh
clear

# Lab 3: Control

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

printf "\n${bold}*** Lab 3: Control Walk Through Cloud Shell #1 ***${normal}\n"
wait

# Ensure pipeline has deployed to canary
printf "\n${bold}Ensure pipelines have deployed canary to production${normal}\n"
wait

# Inspect GATEWAY for the frontend production service
printf "\n${bold}Inspect GATEWAY for the frontend production service${normal}\n"
pe "kubectl get gateway -n production --context gke-central -o yaml"
wait

# Inspect VIRTUALSERVICE for the frontend production service
printf "\n${bold}Inspect VIRTUALSERVICE for the frontend production service${normal}\n"
pe "kubectl get virtualservice frontend -n production --context gke-central -o yaml"
wait

# Inspect DESTINATIONRULE for the frontend production service
printf "\n${bold}Inspect DESTINATIONRULE for the frontend production service${normal}\n"
pe "kubectl get destinationrule frontend -n production --context gke-central -o yaml"
wait

# Inspect deployments in the production namespace
printf "\n${bold}Inspect deployments in the production namespace${normal}\n"
pe "kubectl get deploy -n production --context gke-central"
wait

# Get ingress IP for the production frontend
printf "\n${bold}Get the ingress IP addresses for production frontend${normal}\n"
pe workshop_get-ingress
wait

# Generate some traffic to frontend production using fortio
printf "\n${bold}Generate some traffic to frontend production using fortio${normal}\n"
wait
printf "${bold}While traffic is being generated, open a new Cloud Shell window${normal}\n"

pe "workshop_generate-load"
wait
