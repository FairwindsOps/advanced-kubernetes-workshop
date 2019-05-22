#!/bin/bash

# Get the demo magic
. .demo-magic.sh
clear

# Lab 1 Cloud Shell #2

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

printf "\n${bold}*** Lab 1: Build Walk Through - Cloud Shell Window #2 ***${normal}\n"
wait

printf "\n${bold}Confirm frontend-dev deployed in dev namespace${normal}\n"
pe "kubectl get deploy -n dev --context gke-central"
wait

# Get frontend-dev service external IP address
printf "\n${bold}Get frontend-dev service external IP address${normal}\n"
pe "kubectl get svc -n dev --context gke-central"
wait

# Open Chrome tab with frontend-dev external IP address
printf "\n${bold}Open frontend-dev in an incognito Chrome tab via the external IP address${normal}\n"
wait
printf "${bold}You should see YELLOW background${normal}\n"

# Change background color from YELLOW to GREEN
printf "\n${bold}Change the background color from YELLOW to GREEN.  Switch to Cloud Shell # 1 and inspect skaffold${normal}\n"
pe "sed -i -e s/yellow/green/g $HOME/advanced-kubernetes-workshop/services/frontend/content/index.html"
wait

# After inspecting skaffold rebuild and redeploy, confirm background color changed to GREEN
printf "\n${bold}Upon change, Skaffold rebuilds the new image in GCR repo and redeploys the manifest files automatically${normal}\n"
printf "${bold}Inspect the index.html file and confirm the background color changed${normal}\n"
pe "cat $HOME/advanced-kubernetes-workshop/services/frontend/content/index.html"
wait

# Refresh the Chrome tab and confirm frontend-dev background is GREEN
printf "\n${bold}Refresh the Chrome tab and confirm frontend-dev background is GREEN${normal}\n"
printf "${bold}Get the ingress IP addresses for the production frontend${normal}\n"
pe workshop_get-ingress
wait

# Check frontend prod background color should be YELLOW
printf "\n${bold}Open frontend production in an incognito Chrome tab via the external IP address${normal}\n"
printf "${bold}Confirm background color is YELLOW${normal}\n\n"
wait

# Stop skaffold
printf "\n${bold}Switch to Cloud Shell window #1 (skaffold window) and exit by pressing CTRL-C${normal}\n"

# After exiting skaffold, confirm frontend-dev is removed
printf "\n${bold}After exiting skaffold, confirm frontend-dev deployment is successfully removed${normal}\n"
pe "kubectl get pods -n dev --context gke-central"
