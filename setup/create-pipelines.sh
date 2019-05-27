#!/bin/bash

source ~/advanced-kubernetes-workshop/setup/env.sh

set -x
sed -e s/PROJECT_ID/$PROJECT_ID/g -e s/APP_NAME/$APP_NAME/g -e s/REGION1/Central/g -e s/ONE/central/g ~/advanced-kubernetes-workshop/spinnaker/pipe-one.json | curl -d@- -X     POST --header "Content-Type: application/json" --header     "Accept: /" http://localhost:8080/gate/pipelines
sed -e s/PROJECT_ID/$PROJECT_ID/g -e s/APP_NAME/$APP_NAME/g -e s/REGION2/West/g -e s/TWO/west/g ~/advanced-kubernetes-workshop/spinnaker/pipe-two.json | curl -d@- -X     POST --header "Content-Type: application/json" --header     "Accept: /" http://localhost:8080/gate/pipelines
set +x
