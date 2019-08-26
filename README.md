# Fairwinds Advanced Kubernetes Workshop

# Lab Outline

## Lab 0 - Setup

![Lab 0 Diagram](diagrams/lab-0.png)*Lab 0 Diagram*







## Tools and Repo

+  Clond Repo with workshop files
+  Install following tools in Cloud Shell

    +  `Helm` for application management
    +  `kubectx/kubens` for easy context switching

## Kubernetes Multicluster Architecture (30 mins)

+  Deploy three Kubernetes Engine clusters (5 mins)

    +  Use gcloud
    +  Two clusters (`gke-central` and `gke-east`) used for multi-cluster and application deployment
    +  One cluster (`gke-spinnaker`) used for Spinnaker, NGINX LB and Container Registry

+  Install Istio on all three clusters (5 mins)

    +  Use latest release artifacts (0.8 and onwards will have LTS)
    +  Use Helm
    +  Enable sidecar injector for `gke-central` and `gke-east` for the `default` namespace
    +  For using _Ingress_ and _RouteRules_ later in the lab

+  Install and configure Spinnaker on `gke-spinnaker` (20 mins)

    +  Create service accounts and GCS buckets
    +  Create secret with kubeconfig
    +  Create spinnaker config
    +  Use helm charts by Vic (***chart deployment takes about 10 mins***)

## Application lifecycle management with Spinnaker (20 mins)

+  Prepare Container Registry (5 mins)
    +  Push a simple `web-server` app to Container Registry with version tag `v1.0.0`
    +  Push `busyboxplus` to COntainer registry to simulate canary testing

+  Configure a **Deploy** pipeline in Spinnaker to deploy a web app to both clusters (5 mins)

    +  Deploy Canary > Test Canary > Manual Judgement > Deploy to Prod
    +  Triggered via version tag (`v.*`) from Container Registry

+  Manually deploy pipeline for `v1.0.0` to `gke-central` and `gke-east` (10 mins)

## Load Balancing traffic to gke-central and gke-east (15 mins)

+  Load balance traffic using an NGINX load balancer to both `gke-central` and `gke-east` (10 mins)

    +  Install NGINX LB in `gke-spinnaker` (outside of `gke-central` and `gke-east`)
    +  Configure a ConfigMap for `load-balancer.conf` with `gke-central` and `gke-east` Ingress IP addresses pointing to the webapp
    +  Expose NGINX as `Type:LoadBalancer` for Client access
    +  Manipulate `weight` fields in the ConfigMap to manage traffic between `gke-central` and `gke-east`

## Triggering application updates with Spinnaker (15 mins)

+  Trigger the **Deploy** pipeline by updating the version tag to `v1.0.1` in Container Registry (15 mins)

## Traffic management to prod and canary using Istio (10 mins)

+  Use _RouteRules_ to route traffic between _prod_ and _canary_ releases within each cluster (10 mins)

# Lab Guide

[Lab Guide](lab_guide.md)
