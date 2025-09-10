#!/usr/bin/env bash
set -euo pipefail

# Use: ./setup-kubectl.sh <cluster-name> <region>
CLUSTER_NAME=${1:-"cv-monitoring-cluster"}
REGION=${2:-"eu-central-1"}

aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"
echo "kubeconfig updated for cluster ${CLUSTER_NAME} (region ${REGION})"
