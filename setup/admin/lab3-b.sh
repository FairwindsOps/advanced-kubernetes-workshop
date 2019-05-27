#!/bin/bash

# Get the demo magic
. .demo-magic.sh
clear

# Lab 3: Control Cloud Shell #2

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

printf "\n${bold}*** Lab 3: Control Walk Through Cloud Shell Window #2 ***${normal}\n"
wait

# Inspect Grafana
printf "\n${bold}Inspect Grafana incoming requests by source and destination${normal}\n"
printf "\n${bold}Use Cloud Shell Web Prview to port 3000 and check the Central and West Service Dashboard${normal}\n"
wait

# Appy 50-50 Rule

printf "\n${bold}Apply frontend VIRTUALSERVICE rule to send 50 percent traffic to prod 50 percent traffic to canary${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-50prod-50canary.yml --context gke-central"

# Inspect 50-50 VirtualService rule

printf "\n${bold}Inspect the new frontend VIRTUALSERVICE rule${normal}\n"
wait
pe "kubectl get virtualservice frontend -n production --context gke-central -o yaml"

# Inspect Grafana

printf "\n${bold}Inspect Grafana incoming requests by source and destination${normal}\n"
printf "\n${bold}Inspect the frontend and the backend services${normal}\n"
wait

# Backend destinationrule for prod to prod and canary to canary

printf "\n${bold}Apply backend VIRTUALSERVICE rule to send frontend prod to backend prod and frontend canary to backend canary${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/backend-vs-can-to-can-prod-to-prod.yml --context gke-central"

# Inspect the new backend virtualservice

printf "\n${bold}Inspect the new backend VIRTUALSERVICE rule${normal}\n"
wait
pe "kubectl get virtualservice backend -n production --context gke-central -o yaml"

# Inspect Grafana

printf "\n${bold}Inspect Grafana incoming requests by source and destination${normal}\n"
printf "\n${bold}Inspect the frontend and the backend services${normal}\n"
wait

# Send frontend all to prod

printf "\n${bold}Send all incoming traffic to frontend production${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-all-to-prod.yml --context gke-central"

# Inspect the new frontend virtualservice

printf "\n${bold}Inspect the new frontend VIRTUALSERVICE rule${normal}\n"
wait
pe "kubectl get virtualservice frontend -n production --context gke-central -o yaml"

# Inspect Grafana

printf "\n${bold}Inspect Grafana incoming requests by source and destination${normal}\n"
printf "\n${bold}Inspect the frontend and the backend services${normal}\n"
wait

# Send frontend all to canary

printf "\n${bold}Send all incoming traffic to frontend canary${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/frontend-vs-all-to-canary.yml --context gke-central"

# Inspect the new frontend virtualservice

printf "\n${bold}Inspect the new frontend VIRTUALSERVICE rule${normal}\n"
wait
pe "kubectl get virtualservice frontend -n production --context gke-central -o yaml"

# Inspect Grafana

printf "\n${bold}Inspect Grafana incoming requests by source and destination${normal}\n"
printf "\n${bold}Inspect the frontend and the backend services${normal}\n"
wait

# Reset frontend and backend virtualservices

printf "\n${bold}Reset frontend and backend VIRTUALSERVICE rule${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/services/manifests/myapp-vs-base.yml --context gke-central"

# Rate Limit - frontend production to 75 rps and frontend canary to 20 per 5 secs

printf "\n${bold}Rate limit - frontend prod to 75 req and frontend canary to 20 req per 5 secs${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/lb/rate-limit-frontend.yaml --context gke-central"

# Inspect memquota

printf "\n${bold}Inspect memquota${normal}\n"
wait
pe "kubectl get memquota -n istio-system --context gke-central -o yaml"

# Inspect Grafana

printf "\n${bold}Inspect Grafana incoming requests by source and destination${normal}\n"
printf "\n${bold}Inspect the frontend and the backend services${normal}\n"
wait

# Delete rate limit rule

printf "\n${bold}Delete the rate limit rule${normal}\n"
wait
pe "kubectl delete -f ~/advanced-kubernetes-workshop/lb/rate-limit-frontend.yaml --context gke-central"

# Configure backend circuit breaker

printf "\n${bold}Configure backend circuit breaker through a new backend DESTINATIONRULE${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/lb/circuit-breaker-backend.yml --context gke-central"

# Inspect backend DESTINATIONRULE

printf "\n${bold}Inspect the new backend DESTINATIONRULE${normal}\n"
wait
pe "kubectl get destinationrule backend -n production --context gke-central -o yaml"

# Inspect Grafana

printf "\n${bold}Inspect Grafana incoming requests by source and destination${normal}\n"
printf "\n${bold}Inspect the frontend and the backend services${normal}\n"
wait

# Check circuit breaker

printf "\n${bold}Inspect traffic caught by the circuit breaker${normal}\n"
wait
export FRONTEND_POD=$(kubectl get pods -l app=frontend -n production --context gke-central | awk 'NR == 3 {print $1}')
pe "kubectl exec -it $FRONTEND_POD -n production --context gke-central -c istio-proxy  -- sh -c 'curl localhost:15000/stats' | grep  '||backend.production' | grep pending"

# Reset backend DESTINATIONRULE

printf "\n${bold}Reset the backend DESTINATIONRULE${normal}\n"
wait
pe "kubectl delete -f ~/advanced-kubernetes-workshop/lb/circuit-breaker-backend.yml --context gke-central"
pe "kubectl apply -f ~/advanced-kubernetes-workshop/lb/backend-destination-rule.yml --context gke-central"

# Inspect the security meshpolicy

printf "\n${bold}Inspect the MESHPOLICY for mTLS${normal}\n"
wait
pe "kubectl get meshpolicy -n production --context gke-central -o yaml"

# Verify mTLS configs for frontend and backend in the DESTINATIONRULES

printf "\n${bold}Verify mTLS configs for frontend and backend in the DESTINATIONRULES${normal}\n"
wait
pe "kubectl get destinationrule frontend -n production --context gke-central -o yaml"
pe "kubectl get destinationrule backend -n production --context gke-central -o yaml"

# Inspect frontend service certs in the istio-proxy

printf "\n${bold}Inspect frontend service certs in the istio-proxy${normal}\n"
wait
export FRONTEND_POD=$(kubectl get pods -l app=frontend -n production --context gke-central | awk 'NR == 3 {print $1}')
pe "kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- ls /etc/certs"

# Check the validity of the frontend certs

printf "\n${bold}Inspect the validity of the frontend certs${normal}\n"
wait
pe "kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- cat /etc/certs/cert-chain.pem  | openssl x509 -text -noout  | grep Validity -A 2"

# Inspect frontend service service account

printf "\n${bold}Inspect frontend service service account${normal}\n"
wait
pe "kubectl exec $FRONTEND_POD -n production --context gke-central -c istio-proxy -- cat /etc/certs/cert-chain.pem  | openssl x509 -text -noout  | grep 'Subject Alternative Name' -A 1"

# Confirm backend staging service allows both mTLS and plain text traffic

printf "\n${bold}Confirm backend staging service allows both mTLS and plain text traffic${normal}\n"
wait
pe "kubectl get policy -n staging --context gke-central -o yaml"

# Confirm backend.staging test job does not have an istio-proxy

printf "\n${bold}Confirm backend.staging test job does not have an istio-proxy${normal}\n"
wait
pe "kubectl describe job -n staging --context gke-central"

# Global load balancing

printf "\n${bold}Before configuring global load balancing, finish the spinnaker pipelines${normal}\n"
wait

# Create the NGINX configmap

printf "\n${bold}Configure the NGINX configmap${normal}\n"
wait
export GKE_ONE_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-central)
export GKE_TWO_ISTIO_GATEWAY=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --context gke-west)
pe "kubectx gke-spinnaker"
pe "cd ~/advanced-kubernetes-workshop/lb"
pe "sed -e s/CLUSTER1_INGRESS_IP/$GKE_ONE_ISTIO_GATEWAY\ weight=1/g -e s/CLUSTER2_INGRESS_IP/$GKE_TWO_ISTIO_GATEWAY\ weight=1/g ~/advanced-kubernetes-workshop/lb/glb-configmap-var.yaml > ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml"

# Confirm the NGINX configmap

printf "\n${bold}Confirm the NGINX configmap${normal}\n"
wait
pe "cat ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml"

# Apply the NGINX configmap

printf "\n${bold}Apply the NGINX configmap${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml"

# Create NGINX deployment and service

printf "\n${bold}Create NGINX deployment and service${normal}\n"
wait
pe "kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml"
pe "kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-svc.yaml"

# Get the NGINX service loadbalancer IP address

printf "\n${bold}Get the NGINX service loadbalancer IP address${normal}\n"
wait
pe "kubectl get service global-lb-nginx -w"

# Send traffic to the NGINX loadbalancer IP address

printf "\n${bold}Send traffic to the NGINX loadbalancer IP address${normal}\n"
wait
export GLB_IP=$(kubectl get service global-lb-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
pe "for i in `seq 1 20`; do curl -s $GLB_IP | grep gke | sed -e 's/<p>/ /g' -e 's/<\/p>/ /g'; done"

# Change the NGINX configmap to send more traffic to gke-west vs gke-central

printf "\n${bold}Change the NGINX configmap to send more traffic to gke-west vs gke-central${normal}\n"
wait
sed -e s/CLUSTER1_INGRESS_IP/$GKE_ONE_ISTIO_GATEWAY\ weight=1/g -e s/CLUSTER2_INGRESS_IP/$GKE_TWO_ISTIO_GATEWAY\ weight=4/g ~/advanced-kubernetes-workshop/lb/glb-configmap-var.yaml > ~/advanced-kubernetes-workshop/lb/glb-configmap-2.yaml
pe "kubectl delete -f ~/advanced-kubernetes-workshop/lb/glb-configmap.yaml"
pe "kubectl delete -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml"
pe "kubectl apply -f ~/advanced-kubernetes-workshop/lb/glb-configmap-2.yaml"
pe "kubectl apply -f ~/advanced-kubernetes-workshop/lb/nginx-dep.yaml"

# Inspect the new NGINX configmap

printf "\n${bold}Inspect the new NGINX configmap${normal}\n"
wait
pe "kubectl get configmap nginx --context gke-spinnaker -o yaml | head -7"

# Send traffic to the NGINX loadbalancer IP address

printf "\n${bold}Send traffic to the NGINX loadbalancer IP address${normal}\n"
wait
pe "for i in `seq 1 20`; do curl -s $GLB_IP | grep gke | sed -e 's/<p>/ /g' -e 's/<\/p>/ /g'; done"

# Stop fortio

printf "\n${bold}Stop the fortio traffic generator in Cloud Shell window #1${normal}\n"
wait

# Generate traffic to the NGINX loadbalancer IP address

printf "\n${bold}Generate traffic to the NGINX loadbalancer IP address and inspect Grafana${normal}\n"
wait
pe "workshop_fortio 30m http://$GLB_IP"

