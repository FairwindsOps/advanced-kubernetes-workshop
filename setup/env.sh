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

# DEVSHELL_PROJECT must be set for anything to work.
if [ -z ${DEVSHELL_PROJECT_ID+x} ]; then
    printf "\n${bold}Then environment variable PROJECT needs to be set. Please use gcloud config set project <PROJECT_ID>, where the PROJECT_ID comes from your project.${normal}\n\n"
    exit 1
fi

read -p "Using PROJECT = ${DEVSHELL_PROJECT_ID}. Is this correct? y/n" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

export PROJECT=${DEVSHELL_PROJECT_ID}

### Set initial important variables
# Regions
export ONE=central
export TWO=west

export APP_NAME=myapp
export GCP_USER=$(gcloud config get-value account)

# Versions
export ISTIO_VERSION=1.2.5
export TERRAFORM_VERSION=0.11.13
