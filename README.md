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

2. cd service/infra
3. terraform init
4. terraform apply

5. cd ../.. 
6. chmod +x ./service/scripts/setup-kubectl.sh
7. ./service/scripts/setup-kubectl.sh <cluster-name> <region>

8. **Create a .env file and set environment variables (do NOT commit these):**  
GRAFANA_ADMIN_PASSWORD=YourGrafanaPass  
SMTP_SMARTHOST=smtp.example.com:587  
SMTP_FROM=alerts@example.com  
SMTP_USER=smtp-user  
SMTP_PASS=smtp-pass  
ALERT_TO=your-email@example.com
9. export $(grep -v '^#' .env | xargs)

10. chmod +x ./service/scripts/deploy-monitoring.sh
11. ./service/scripts/deploy-monitoring.sh

12. **Access Grafana UI**  
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80  
open http://localhost:3000  (user: admin, password: GRAFANA_ADMIN_PASSWORD)  

13. **Access Prometheus UI**  
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090  
open http://localhost:9090  

14. **Access Alert Manager UI**  
kubectl -n monitoring port-forward svc/kube-prometheus-stack-alertmanager 9093:9093  
open http://localhost:9093  

15. **Trigger a demo alert (scale stress pod to increase CPU Utilisation):**  
kubectl -n demo scale deploy/stress-cpu --replicas=4  
(or --replicas=5 if you want faster process to increase the CPU >70%)
wait a couple minutes; monitor Grafana / Prometheus and check mail for Alertmanager notification  

16. cd service/infra  
terraform destroy

### B) Local Kubernetes (kind / minikube) — quick test  
(Note that local resources might not be sufficient for the proper functioning of the service.)

1. Create a .env file and set environment variables (same as in A version)
2. export $(grep -v '^#' .env | xargs)

3. kind create cluster --name monitoring-demo  
or: minikube start  
(you can add more CPU and memory with --cpus= and --memory=)

4. chmod +x ./service/scripts/deploy-monitoring.sh
5. ./service/scripts/deploy-monitoring.sh

6. You have to wait until the pods start up before you can access services
You can check pods:
kubectl get pods -n monitoring

7. Access Grafana/Prometheus/Alertmanager as in A version and trigger the stress pod scale.

8. kind delete cluster --name monitoring-demo  
or: minikube stop && minikube delete

