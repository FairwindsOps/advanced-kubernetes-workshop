#!/bin/bash

# Get the demo magic
. .demo-magic.sh
clear

# Lab 2

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

printf "\n${bold}*** Lab 2: Deploy Walk Through ***${normal}\n"
wait

# Open ports
printf "\n${bold}Open ports to Spinnaker, Grafana, Prometheus, Jaeger and ServiceGraph${normal}\n"
pe workshop_connect

# Open Spinnaker GUI
printf "\n${bold}Open Spinnaker GUI on port 8080 using Cloud Shell Web Preview${normal}\n"
wait

# Get frontend-dev service external IP address
printf "\n${bold}Deploy spinnaker pipelines for GKE-Central and GKE-West clusters${normal}\n"
wait

pe workshop_create-pipelines
wait

printf "\n${bold}Confirm the pipelines are deployed in Spinnaker${normal}\n"
wait

# Build and trigger Spinnaker pipelines
printf "\n${bold}Build new new frontend image and trigger Spinnaker pipelines${normal}\n"
pe "cd ~/advanced-kubernetes-workshop/services/frontend/; ./build.sh"
