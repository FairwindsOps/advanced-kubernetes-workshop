#!/bin/bash

set -e

# Get the workshop environment variables, just in case. Also checks for necessary variables
source ~/advanced-kubernetes-workshop/setup/env.sh

set -x
sed -e s/PROJECT_ID/$PROJECT/g -e s/APP_NAME/$APP_NAME/g -e s/REGION1/Central/g -e s/ONE/central/g ~/advanced-kubernetes-workshop/spinnaker/pipe-one.json | curl -d@- -X     POST --header "Content-Type: application/json" --header     "Accept: /" http://localhost:8080/gate/pipelines
sed -e s/PROJECT_ID/$PROJECT/g -e s/APP_NAME/$APP_NAME/g -e s/REGION2/West/g -e s/TWO/west/g ~/advanced-kubernetes-workshop/spinnaker/pipe-two.json | curl -d@- -X     POST --header "Content-Type: application/json" --header     "Accept: /" http://localhost:8080/gate/pipelines
set +x
