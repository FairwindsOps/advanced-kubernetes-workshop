#!/usr/bin/env bash

if [ ! $CLOUD_SHELL ]; then
    printf "\n${bold}You're not running inside Google Cloud Shell! This is not recommended. Exiting.\n\n${normal}"
    return
    exit 1
fi

pkill -f port-forward

# Expose DECK on Port 8080 for Spinnaker frontend
DECK_PORT=8080
kubectl port-forward svc/spin-deck $DECK_PORT:9000 -n default --context gke-spinnaker >> /dev/null &
echo "Spinnaker Deck Port opened on $DECK_PORT"


# Expose PROMETHEUS on Port 9090 (1) and 9091 (2)
PROM_PORT_1=9090
PROM_PORT_2=9091
kubectl port-forward svc/prometheus $PROM_PORT_1:9090 -n istio-system --context gke-ONE >> /dev/null &
echo "Prometheus Port opened on $PROM_PORT_1 for gke-ONE"
kubectl port-forward svc/prometheus $PROM_PORT_2:9090 -n istio-system --context gke-TWO >> /dev/null &
echo "Prometheus Port opened on $PROM_PORT_2 for gke-TWO"

# Expose GRAFANA on Port 3000 (1) and 3001 (2)
GRAFANA_PORT_1=3000
GRAFANA_PORT_2=3001
GRAFANA_PORT_3=4000
kubectl port-forward svc/grafana $GRAFANA_PORT_1:3000 -n istio-system --context gke-ONE >> /dev/null &
echo "Grafana Port opened on $GRAFANA_PORT_1 for gke-ONE"
kubectl port-forward svc/grafana $GRAFANA_PORT_2:3000 -n istio-system --context gke-TWO >> /dev/null &
echo "Grafana Port opened on $GRAFANA_PORT_2 for gke-TWO"
kubectl port-forward svc/grafana $GRAFANA_PORT_3:3000 -n istio-system --context gke-spinnaker >> /dev/null &
echo "Grafana Port opened on $GRAFANA_PORT_3 for gke-spinnaker"

# Expose JAEGER on Port 16686 (1) and 16687 (2)
JAEGER_PORT_1=16686
JAEGER_PORT_2=16687
kubectl port-forward svc/jaeger-query $JAEGER_PORT_1:16686 -n istio-system --context gke-ONE >> /dev/null &
echo "Jaeger Port opened on $JAEGER_PORT_1 for gke-ONE"
kubectl port-forward svc/jaeger-query $JAEGER_PORT_2:16686 -n istio-system --context gke-TWO >> /dev/null &
echo "Jaeger Port opened on $JAEGER_PORT_2 for gke-TWO"

# Expose ServiceGraph
SERVICEGRAPH_PORT_1=8088
SERVICEGRAPH_PORT_2=8089
kubectl port-forward svc/servicegraph $SERVICEGRAPH_PORT_1:8088 -n istio-system --context gke-ONE >> /dev/null &
echo "Servicegraph port opened on $SERVICEGRAPH_PORT_1 for gke-ONE"
kubectl port-forward svc/servicegraph $SERVICEGRAPH_PORT_2:8089 -n istio-system --context gke-TWO >> /dev/null &
echo "Servicegraph port opened on $SERVICEGRAPH_PORT_2 for gke-TWO"


# Expose KIALI on Port 20001 (1) and 20002 (2)
KIALI_PORT_1=20001
KIALI_PORT_2=20002
kubectl port-forward svc/kiali $KIALI_PORT_1:20001 -n istio-system --context gke-ONE >> /dev/null &
echo "Kiali Port opened on $KIALI_PORT_1 for gke-ONE"
kubectl port-forward svc/kiali $KIALI_PORT_2:20001 -n istio-system --context gke-TWO >> /dev/null &
echo "Kiali Port opened on $KIALI_PORT_2 for gke-TWO"
