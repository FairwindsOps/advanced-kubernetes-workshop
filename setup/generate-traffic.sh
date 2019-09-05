#!/bin/bash

source ~/bin/workshop_get-ingress

workshop_fortio 600m http://$GKE_ONE_ISTIO_GATEWAY &
workshop_fortio 600m http://$GKE_TWO_ISTIO_GATEWAY &
