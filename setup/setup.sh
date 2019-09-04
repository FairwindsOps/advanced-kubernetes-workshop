#!/bin/bash

SECONDS=0

# Set speed, bold and color variables
SPEED=40
bold=$(tput bold)
normal=$(tput sgr0)
color='\e[1;32m' # green
nc='\e[0m'

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

if [ -z ${PROJECT+x} ]; then
    printf "\n${bold}Then environment variable PROJECT needs to be set. Please use gcloud config set project <PROJECT_ID>, where the PROJECT_ID comes from your project.${normal}\n\n"
    return
    exit 1
fi

printf "\n${bold}Starting Setup Script....\n${normal}"


### Set initial important variables
source $HOME/advanced-kubernetes-workshop/setup/env.sh

#######################
## Install Utilities ##
#######################

# Create bin path and install workshop commands
echo "${bold}Creating local ~/bin folder...${normal}"
mkdir -p $HOME/bin
PATH=$HOME/bin/:$PATH

cp $HOME/advanced-kubernetes-workshop/setup/connect.sh $HOME/bin/workshop_connect
chmod +x $HOME/bin/workshop_connect

cp $HOME/advanced-kubernetes-workshop/setup/get-ingress.sh $HOME/bin/workshop_get-ingress
chmod +x $HOME/bin/workshop_get-ingress

cp $HOME/advanced-kubernetes-workshop/setup/fortio.sh $HOME/bin/workshop_fortio
chmod +x $HOME/bin/workshop_fortio

cp $HOME/advanced-kubernetes-workshop/setup/apply-terraform.sh $HOME/bin/workshop_terraform-apply
chmod +x $HOME/bin/workshop_terraform-apply

cp $HOME/advanced-kubernetes-workshop/setup/halconfig.sh $HOME/bin/workshop_hal-config
chmod +x $HOME/bin/workshop_hal-config

cp $HOME/advanced-kubernetes-workshop/setup/create-pipelines.sh $HOME/bin/workshop_create-pipelines
chmod +x $HOME/bin/workshop_create-pipelines
echo "********************************************************************************"

# Create SSH key
mkdir -p $HOME/.ssh
if [ ! -f $HOME/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f $HOME/.ssh/id_rsa &> /dev/null
fi

# Install kubectx/kubens
echo "${bold}Installing kubectx for easy cluster context switching...${normal}"
rm -f $HOME/bin/kubectx || true
rm -f $HOME/bin/kubens || true

curl -Ls -o $HOME/bin/kubens https://raw.githubusercontent.com/ahmetb/kubectx/v0.6.3/kubens
curl -Ls -o $HOME/bin/kubectx https://raw.githubusercontent.com/ahmetb/kubectx/v0.6.3/kubectx

chmod +x $HOME/bin/kubectx
chmod +x $HOME/bin/kubens
echo "********************************************************************************"

# Install kubectl aliases
echo "${bold}Installing kubectl_aliases...${normal}"
cd $HOME
if [ -d $HOME/kubectl-aliases ]; then
    rm -rf $HOME/kubectl-aliases
fi
git clone https://github.com/ahmetb/kubectl-aliases.git $HOME/kubectl-aliases
echo "[ -f $HOME/kubectl-aliases/.kubectl_aliases ] && source $HOME/kubectl-aliases/.kubectl_aliases" >> $HOME/.bashrc
source $HOME/.bashrc
echo "********************************************************************************"

# Install Helm
echo "${bold}Installing helm...${normal}"
if [ -f get_helm.sh ]; then
    rm get_helm.sh
fi
curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh &> /dev/null
cp -f /usr/local/bin/helm $HOME/bin/
echo "********************************************************************************"

# Install hey
echo "${bold}Installing hey...${normal}"
go get -u github.com/rakyll/hey
echo "********************************************************************************"

# Install html2text
echo "${bold}Installing html2text...${normal}"
sudo pip install html2text
cp /usr/local/bin/html2text $HOME/bin/
echo "********************************************************************************"

# Install some utilities
sudo apt-get update
sudo apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install pv unzip
cp /usr/bin/pv $HOME/bin/
cp /usr/bin/unzip $HOME/bin/

# Install terraform
echo "${bold}Installing terraform...${normal}"

mkdir -p $HOME/terraform11
cd $HOME/terraform11
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform $HOME/bin/.
cd $HOME
echo "********************************************************************************"

# Install krompt and other profile customizations
cd $HOME
cat $HOME/advanced-kubernetes-workshop/setup/krompt.txt >> $HOME/.bashrc
source $HOME/.bashrc

# Download Istio
echo "${bold}Downloading Istio...${normal}"
cd $HOME
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
ln -sf $HOME/istio-$ISTIO_VERSION/bin/istioctl $HOME/bin/istioctl
echo "********************************************************************************"

############################
## END: Install utilities ##
############################

################################
## Replace variables in files ##
################################
echo "${bold}Replacing the necessary variables in files....${normal}"
sed -i -e s/ONE/$ONE/g -e s/TWO/$TWO/g $HOME/bin/workshop_connect
sed -i -e s/ONE/$ONE/g -e s/TWO/$TWO/g $HOME/bin/workshop_get-ingress

sed -i -e s/ONE/$ONE/g -e s/TWO/$TWO/g $HOME/bin/workshop_hal-config

sed -i -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-workshop/services/frontend/skaffold.yaml
sed -i -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-workshop/services/frontend/k8s-frontend-dev.yml
sed -i -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-workshop/services/manifests/frontend.yml
sed -i -e s/PROJECT_ID/$PROJECT/g $HOME/advanced-kubernetes-workshop/services/manifests/backend.yml

#####################################
## END: Replace variables in files ##
#####################################


######################################
## Service Accounts and Permissions ##
######################################

# Create Terraform service account
echo "${bold}Creating GCP service account for Terraform...${normal}"
gcloud iam service-accounts describe terraform@${PROJECT}.iam.gserviceaccount.com 2>/dev/null || gcloud iam service-accounts create terraform --display-name terraform-sa

while [ -z "$TERRAFORM_SA_EMAIL" ]
do
  export TERRAFORM_SA_EMAIL=$(gcloud iam service-accounts list \
      --filter="displayName:terraform-sa" \
      --format='value(email)')
done
echo "********************************************************************************"

# Create Spinnaker service account
echo "${bold}Creating GCP service account for Spinnaker...${normal}"
gcloud iam service-accounts describe spinnaker@${PROJECT}.iam.gserviceaccount.com 2>/dev/null || gcloud iam service-accounts create spinnaker --display-name spinnaker-service-account
while [ -z "$SPINNAKER_SA_EMAIL" ]
do
  export SPINNAKER_SA_EMAIL=$(gcloud iam service-accounts list \
      --filter="displayName:spinnaker-service-account" \
      --format='value(email)')
done
echo "********************************************************************************"

# Get email for the GCE default service account
export GCE_EMAIL=$(gcloud iam service-accounts list --format='value(email)' | grep compute)
echo $(gcloud info --format='value(config.project)') > $HOME/project.txt

# Give Terraform SA and GCE default SA roles/owner IAM permissions
echo "${bold}Creating GCP IAM role bindings for terraform and spinnaker service accounts...${normal}"
gcloud projects add-iam-policy-binding $PROJECT --role roles/owner --member serviceAccount:$TERRAFORM_SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT --role roles/owner --member serviceAccount:$SPINNAKER_SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT --role roles/owner --member serviceAccount:$GCE_EMAIL
gcloud projects add-iam-policy-binding $PROJECT --role roles/owner --member user:$(gcloud config list account --format "value(core.account)")
echo "********************************************************************************"

# Get creds for Terraform SA
echo "${bold}Creating credentials for terraform service account...${normal}"
gcloud iam service-accounts keys create $HOME/advanced-kubernetes-workshop/setup/terraform/credentials.json --iam-account $TERRAFORM_SA_EMAIL
echo "********************************************************************************"

# Get creds for Spinnaker SA
echo "${bold}Creating credentials for spinnaker service account...${normal}"
gcloud iam service-accounts keys create $HOME/advanced-kubernetes-workshop/setup/spinnaker-service-account.json --iam-account $SPINNAKER_SA_EMAIL
echo "********************************************************************************"

# Make GCR repo public for all users
gsutil iam ch allUsers:objectViewer gs://artifacts.$PROJECT.appspot.com

# Setup Spinnaker Config
echo "${bold}Configuring spinnaker...${normal}"
export JSON=$(cat $HOME/advanced-kubernetes-workshop/setup/spinnaker-service-account.json)

cat > $HOME/advanced-kubernetes-workshop/setup/spinconfig.yaml <<EOF
minio:
  enabled: false
gcs:
  enabled: true
  project: $PROJECT
  bucket: "$PROJECT-spinnaker-config"
  jsonKey: '$JSON'
EOF
echo "********************************************************************************"

###########################################
## END: Service Accounts and Permissions ##
###########################################

# Create application frontend
echo "${bold}Creating frontend service container in gcr.io...${normal}"
cd $HOME/advanced-kubernetes-workshop/services/frontend
gcloud builds submit -q --tag gcr.io/$PROJECT/frontend .
cd $HOME
echo "********************************************************************************"

# Create application backend
echo "${bold}Creating backend service container in gcr.io...${normal}"
cd $HOME/advanced-kubernetes-workshop/services/backend
gcloud builds submit -q --tag gcr.io/$PROJECT/backend .
cd $HOME
echo "********************************************************************************"

# Create application frontend-dev
echo "${bold}Creating frontend-dev service container in gcr.io...${normal}"
cd $HOME/advanced-kubernetes-workshop/services/frontend
gcloud builds submit -q --tag gcr.io/$PROJECT/frontend-dev .
cd $HOME
echo "********************************************************************************"

# Create application backend-dev
echo "${bold}Creating backend-dev service container in gcr.io...${normal}"
cd $HOME/advanced-kubernetes-workshop/services/backend
gcloud builds submit -q --tag gcr.io/$PROJECT/backend-dev .
cd $HOME
echo "********************************************************************************"

###############
## Terraform ##
###############
echo "${bold}Running terraform....${normal}"
workshop_terraform-apply
echo "${bold}Waiting 30s and then running terraform again....${normal}"
sleep 30
workshop_terraform-apply

echo "${bold}Configuring Spinnaker using hal...${normal}"
workshop_hal-config

workshop_connect
echo "${bold}Setting up grafana dashboards...${normal}"
~/advanced-kubernetes-workshop/setup/grafana.sh
cd $HOME

echo $SECONDS
