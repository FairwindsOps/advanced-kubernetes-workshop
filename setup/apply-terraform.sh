###############
## Terraform ##
###############

if [ ! $CLOUD_SHELL ]; then
    printf "\n${bold}You're not running inside Google Cloud Shell! This is not recommended. Exiting.\n\n${normal}"
    return
    exit 1
fi

### Set initial important variables
source $HOME/advanced-kubernetes-workshop/setup/env.sh

echo "${bold}Start terraform script...${normal}"
cd $HOME/advanced-kubernetes-workshop/setup/terraform
terraform init
terraform apply \
    -var "homedir=${HOME}" \
    -var "project=$PROJECT" \
    -var "istio-ver=$ISTIO_VERSION" \
    -var "user=$GCP_USER" \
    -auto-approve

