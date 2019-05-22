#!/bin/bash

kubectl cp ~/advanced-kubernetes-workshop/setup/spinnaker-service-account.json default/spin-spinnaker-halyard-0:/home/spinnaker/. --context gke-spinnaker
kubectl cp ~/project.txt default/spin-spinnaker-halyard-0:/home/spinnaker/. --context gke-spinnaker
kubectl cp ~/.kube/config default/spin-spinnaker-halyard-0:/home/spinnaker/.kube/. --context gke-spinnaker

# Set the kube context correctly
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "kubectl config use-context gke-spinnaker"

# Add the two kubernetes accounts ONE and TWO
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "\
    hal config provider kubernetes account delete gke-ONE 2>/dev/null || true ; \
    hal config provider kubernetes account add gke-ONE --provider-version v2 --context gke-ONE"

kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "\
    hal config provider kubernetes account delete gke-TWO 2>/dev/null || true; \
    hal config provider kubernetes account add gke-TWO --provider-version v2 --context gke-TWO"

# Enable artifact repo
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "hal config features edit --artifacts true"
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "hal config artifact gcs account add spinnaker-service-account --json-path /home/spinnaker/spinnaker-service-account.json"
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "hal config artifact gcs enable"

# Add gcr registry
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "hal config provider docker-registry enable"
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "\
    hal config provider docker-registry account delete gcr-registry 2>/dev/null || true; \
    hal config provider docker-registry account add gcr-registry \
    --address gcr.io \
    --username _json_key \
    --password-file /home/spinnaker/spinnaker-service-account.json"

# Enable pubsub
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "hal config pubsub google enable"

# Add gcr subscription if it doesn't exist
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "\
    hal config pubsub google subscription delete gcr-google-pubsub 2>/dev/null || true; \
    hal config pubsub google subscription add gcr-google-pubsub \
    --subscription-name my-gcr-sub \
    --json-path /home/spinnaker/spinnaker-service-account.json \
    --project $(cat ~/project.txt) \
    --message-format GCR"

# Add gcs subscription if it doesn't exist
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "\
    hal config pubsub google subscription delete gcs-google-pubsub 2>/dev/null || true; \
    hal config pubsub google subscription add gcs-google-pubsub \
    --subscription-name my-gcs-sub \
    --json-path /home/spinnaker/spinnaker-service-account.json \
    --project $(cat ~/project.txt) \
    --message-format GCS"

# Apply the config
kubectl exec spin-spinnaker-halyard-0 --context gke-spinnaker -- bash -c "hal deploy apply"

echo "Don't forget to run workshop_connect in order to connect to Spinnaker!"
