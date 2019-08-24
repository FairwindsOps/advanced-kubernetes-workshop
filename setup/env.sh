#!/bin/bash

# If the script is not sourced, then don't run it.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    printf "\nScript ${BASH_SOURCE[0]} needs to be sourced, not run directly!!\n${bold}Try running 'source ${BASH_SOURCE[0]}'\n\n${normal}"
    exit 1
fi

if [ ! $CLOUD_SHELL ]; then
    printf "\n${bold}You're not running inside Google Cloud Shell! This is not recommended. Exiting.\n\n${normal}"
    return
    exit 1
fi

### Set initial important variables
# Regions
export ONE=central
export TWO=west

# Project
export PROJECT=$(gcloud info --format='value(config.project)')
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export APP_NAME=myapp
export GCP_USER=$(gcloud config get-value account)

# Versions
export ISTIO_VERSION=1.2.5
export TERRAFORM_VERSION=0.11.13
