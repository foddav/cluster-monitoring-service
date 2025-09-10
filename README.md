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


### A) AWS EKS (Terraform) — full infra-as-code flow
1. Edit terraform.tfvars to set region, cluster_name, node type, etc.
2. cp terraform.tfvars.example terraform.tfvars

3. terraform init
4. terraform apply -auto-approve

5. terraform output kubeconfig_cmd
6. run the printed `aws eks update-kubeconfig --name ... --region ...` command  
or:  
./service/scripts/setup-kubectl.sh <cluster-name> <region>

7. **Set environment variables for deploy (do NOT commit these):**  
export GRAFANA_ADMIN_PASSWORD="YourGrafanaPass"  
export SMTP_SMARTHOST="smtp.example.com:587"  
export SMTP_FROM="alerts@example.com"  
export SMTP_USER="smtp-user"  
export SMTP_PASS="smtp-pass"  
export ALERT_TO="your-email@example.com"

8. ./service/scripts/deploy-monitoring.sh  

9. **Access Grafana UI**  
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80  
open http://localhost:3000  (user: admin, password: GRAFANA_ADMIN_PASSWORD)  

10. **Access Prometheus UI**  
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090  
open http://localhost:9090  

11. **Access Alert Manager UI**  
kubectl -n monitoring port-forward svc/kube-prometheus-stack-alertmanager 9093:9093  
open http://localhost:9093  

12. **Trigger a demo alert (scale stress pod):**  
kubectl -n demo scale deploy/stress-cpu --replicas=3  
wait a couple minutes; monitor Grafana / Prometheus and check mail for Alertmanager notification  

13. cd service/infra  
terraform destroy -auto-approve

### B) Local Kubernetes (kind / minikube) — quick test
1. kind create cluster --name monitoring-demo  
or: minikube start

2. From repo root set environment variables (same as in A)

3. ./service/scripts/deploy-monitoring.sh

4. Access Grafana/Prometheus/Alertmanager as in A version and trigger the stress pod scale.

5. kind delete cluster --name monitoring-demo  
or: minikube stop && minikube delete

