#!/usr/bin/env bash
set -euo pipefail

# local system and deploy script (do not commit passwords)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

# enviromental variables to export (do not commit)
: "${GRAFANA_ADMIN_PASSWORD:?Set GRAFANA_ADMIN_PASSWORD env var}"
: "${SMTP_SMARTHOST:?Set SMTP_SMARTHOST env var (e.g. smtp.mailtrap.io:587)}"
: "${SMTP_FROM:?Set SMTP_FROM env var (e.g. alerts@example.com)}"
: "${SMTP_USER:?Set SMTP_USER env var}"
: "${SMTP_PASS:?Set SMTP_PASS env var}"
: "${ALERT_TO:?Set ALERT_TO env var}"

# render values file
envsubst < ./k8s/prometheus-values.yaml > /tmp/prometheus-values.yaml

# add helm repo & install
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update || true

kubectl create namespace monitoring || true
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring -f /tmp/prometheus-values.yaml

# apply alert rules and stress app
kubectl apply -f ./k8s/prometheus-alerts.yaml -n monitoring
kubectl create namespace demo || true
kubectl apply -f ./k8s/stress-deployment.yaml -n demo

echo "Deployed monitoring stack and demo workload."
echo "To access Grafana: kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80"
echo "Grafana admin user: admin, password from env GRAFANA_ADMIN_PASSWORD."
