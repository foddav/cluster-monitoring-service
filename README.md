# Cluster Monitoring Service — Terraform + EKS + Prometheus & Grafana
 
This project is an **end-to-end Kubernetes/EKS cluster monitoring solution** using Terraform, Prometheus, Grafana and Alertmanager. The stack includes a small demo workload (stress pod) that can trigger alerts (email) to demonstrate the detection → alerting flow.
This project was created as part of my DevOps learning journey and portfolio.

---

## 📊 About the project
This repository demonstrates how to provision infrastructure-as-code (Terraform) on AWS (EKS) and deploy a full observability stack on Kubernetes using Helm. The stack is based on the `kube-prometheus-stack` chart (Prometheus, Alertmanager, Grafana, node-exporter, kube-state-metrics). A demo `stress` deployment lets you simulate high CPU load and validate Prometheus alerting and Alertmanager notifications.  

---

## 📌 Project Goals
- Provide a reproducible **infra-as-code** example for AWS EKS with Terraform.
- Deploy a **production-oriented monitoring stack** (metrics collection, visualization, alerting).
- Demonstrate **incident simulation** via a demo workload and **automated alert** delivery (email).
- Keep the project following common **DevOps best practices** (secrets handling, namespaces, clear scripts).

---

## ⚙️ Technologies Used
- **Terraform** (infra provisioning)
- **AWS EKS** (managed Kubernetes) — optional; local alternatives supported
- **Helm** (chart deployment)
- **Prometheus, Alertmanager, Grafana** (monitoring & alerting)
- **node-exporter, kube-state-metrics** (metric exporters)
- **stress-ng** (demo workload container)
- **kubectl, helm, aws-cli, kind/minikube** (developer tools)
- **Bash scripts for setup and deploy**

---

## 📝 How To Run
This repo supports two modes:
- AWS EKS (Terraform) — "production-style" — create EKS cluster via Terraform and deploy the monitoring stack to it.
- Local Kubernetes (kind / minikube) — fast, free local testing (skip Terraform).


# A) AWS EKS (Terraform) — full infra-as-code flow
Edit terraform.tfvars to set region, cluster_name, node type, etc.
cp terraform.tfvars.example terraform.tfvars

terraform init
terraform apply -auto-approve

terraform output kubeconfig_cmd
run the printed `aws eks update-kubeconfig --name ... --region ...` command
or:
./service/scripts/setup-kubectl.sh <cluster-name> <region>

**Set environment variables for deploy (do NOT commit these):**
export GRAFANA_ADMIN_PASSWORD="YourGrafanaPass"
export SMTP_SMARTHOST="smtp.example.com:587"
export SMTP_FROM="alerts@example.com"
export SMTP_USER="smtp-user"
export SMTP_PASS="smtp-pass"
export ALERT_TO="your-email@example.com"

./service/scripts/deploy-monitoring.sh

**Access Grafana UI**
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
open http://localhost:3000  (user: admin, password: GRAFANA_ADMIN_PASSWORD)

**Access Prometheus UI**
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
open http://localhost:9090

**Alert Manager UI**
kubectl -n monitoring port-forward svc/kube-prometheus-stack-alertmanager 9093:9093
open http://localhost:9093

**Trigger a demo alert (scale stress pod):**
kubectl -n demo scale deploy/stress-cpu --replicas=3
wait a couple minutes; monitor Grafana / Prometheus and check mail for Alertmanager notification

cd service/infra
terraform destroy -auto-approve

# B) Local Kubernetes (kind / minikube) — quick test
kind create cluster --name monitoring-demo
or: minikube start

**From repo root set environment variables (same as in A):**
export GRAFANA_ADMIN_PASSWORD="localpass"
export SMTP_SMARTHOST="smtp.mailtrap.io:587"
export SMTP_FROM="alerts@local.test"
export SMTP_USER="user"
export SMTP_PASS="pass"
export ALERT_TO="you@local.test"

./service/scripts/deploy-monitoring.sh

Access Grafana/Prometheus/Alertmanager as in A version and trigger the stress pod scale.

kind delete cluster --name monitoring-demo
or: minikube stop && minikube delete

