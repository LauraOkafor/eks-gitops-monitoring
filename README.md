# ☁️ TaskFlow: A Cloud-Native Application Platform on AWS EKS

> **Production-Grade Kubernetes Deployment with GitOps, Monitoring, Auto-Scaling & Security – Fully Automated with Terraform**

---

## 📌 Project Overview

**TaskFlow** is a cloud-native platform designed to demonstrate how to build, deploy, and operate modern applications in production using **Kubernetes on AWS EKS**. It covers real-world DevOps practices including:

- Infrastructure as Code with **Terraform**
- GitOps using **ArgoCD**
- Application monitoring with **Prometheus & Grafana**
- Secure access control via **RBAC** and **NetworkPolicies**
- Auto-scaling with **HPA** and **metrics-server**
- Deployment of a full-stack microservice app (**React + Node.js + PostgreSQL**)

The platform is built with **production readiness** in mind and provides a blueprint for scalable, observable, and secure application delivery on Kubernetes.

---

## 🎯 Goals of the Project

- ✅ Deploy a real-world application on **EKS** using **IaC**
- ✅ Implement **GitOps** with ArgoCD for declarative deployments
- ✅ Integrate full **observability** with metrics and dashboards
- ✅ Enable **auto-healing** and **auto-scaling**
- ✅ Enforce **network isolation** and **least-privilege RBAC**
- ✅ Document the architecture, workflow, and results

---

## 🛠️ Technologies Used

| Category            | Tools / Services                          |
|---------------------|-------------------------------------------|
| Cloud               | AWS (EKS, IAM, CloudWatch)                |
| IaC                 | Terraform, Helm                           |
| Orchestration       | Kubernetes, eksctl                        |
| GitOps              | ArgoCD                                    |
| Monitoring          | Prometheus, Grafana, kube-state-metrics  |
| Logging             | CloudWatch (optionally Loki/EFK)         |
| CI/CD               | GitHub, Git triggers, Argo auto-sync     |
| App Stack           | React (frontend), Node.js (backend), PostgreSQL |
| Security            | Kubernetes RBAC, Network Policies         |
| Scaling             | HPA, metrics-server                       |

---

## 🧱 Architecture

The infrastructure and services are split into distinct namespaces with RBAC and NetworkPolicy controls.
Users ⇄ LoadBalancer (frontend) ⇄ React App
⇅
Node.js API (backend)
⇅
PostgreSQL Database

📷 Architecture Diagram Here 
![eks-gitops-arch Large](https://github.com/user-attachments/assets/834d64ec-d18d-437d-9548-d24c692a5eb9)


---

## 🗓️ Project outcome

|     | Focus Area                             | Outcome                                               |
|-----|----------------------------------------|--------------------------------------------------------|
| 1   | EKS + Application Deployment           | EKS created, app deployed to cluster, exposed via LB   |
| 2   | Monitoring & Health Checks             | Prometheus + Grafana integrated, health probes added   |
| 3   | GitOps Setup (Part 1)                  | ArgoCD installed, GitHub repo structured               |
| 4   | GitOps Automation (Part 2)             | Auto-sync enabled, rollback tested, dev/prod split     |
| 5   | Scaling & Security                     | HPA configured, RBAC applied, network policies set     |
| 6   | Centralized Logging & Final Testing    | Logs integrated, cleanup done, auto-heal tested        |

---

## ⚙️ Setup Instructions

### ✅ Prerequisites

- AWS CLI configured with appropriate access
- Installed: `kubectl`, `eksctl`, `helm`, `terraform`, `docker`
- A public GitHub repository
- DockerHub account (optional)

### 🚀 1. Provision EKS Cluster (Terraform)

```bash
cd terraform/
terraform init
terraform apply
  •	Creates EKS cluster, IAM roles, VPC networking
	•	Deploys Node Groups and configures kubeconfig
```
<img width="1440" alt="Screenshot 2025-06-10 at 03 14 57" src="https://github.com/user-attachments/assets/a385f904-cf6b-44d0-8197-bfe9e15bcf8e" />


## 🔁 GitOps Workflow
	1.	ArgoCD monitors GitHub repo
	2.	On git push, ArgoCD auto-syncs and deploys updates
	3.	Supports rollback and environment separation (dev/prod)

 <img width="1440" alt="Screenshot 2025-06-10 at 03 51 08" src="https://github.com/user-attachments/assets/5f661290-6504-47df-8cce-4e3b7c55ef27" />
<img width="1440" alt="Screenshot 2025-06-10 at 03 51 00" src="https://github.com/user-attachments/assets/1b63424f-5f22-4656-a433-59440018cfe6" />


## 📊 Monitoring

Monitoring is handled using Prometheus, Grafana, and kube-state-metrics.

🔧 Stack Includes:
	•	Prometheus: for metrics collection from Kubernetes and apps
	•	Grafana: for beautiful, interactive dashboards
	•	kube-state-metrics: for resource-level visibility

** 📺 Accessing Grafana Dashboard
kubectl port-forward svc/grafana -n monitoring 3000:80
<img width="1440" alt="Screenshot 2025-06-10 at 00 45 32" src="https://github.com/user-attachments/assets/250f9360-cab6-46a4-b444-18b922625c0b" />
<img width="1440" alt="Screenshot 2025-06-10 at 00 44 38" src="https://github.com/user-attachments/assets/5f4fd0a3-5a83-4ba4-ba4c-56f9b9418789" />
<img width="1440" alt="Screenshot 2025-06-10 at 00 44 24" src="https://github.com/user-attachments/assets/f7151e6b-ee17-4080-9396-8cc11e4fe1e4" />
<img width="1440" alt="Screenshot 2025-06-10 at 00 43 07" src="https://github.com/user-attachments/assets/4475088c-4d83-4340-bca9-9c8ba9c2f493" />
<img width="1440" alt="Screenshot 2025-06-10 at 00 42 17" src="https://github.com/user-attachments/assets/10825858-b205-4850-b97a-3823bd67815e" />
<img width="1440" alt="Screenshot 2025-06-10 at 00 47 23" src="https://github.com/user-attachments/assets/7b4e373b-68c2-4833-8780-07836edc9968" />

## 🔒 Security & ⚖️ Scaling
** 🔒 Security
	•	RBAC: Role-based access control by namespace
	•	NetworkPolicies: Enforces traffic rules between pods
	•	Follows least-privilege and zero-trust principles

** ⚖️ Scaling
	•	Horizontal Pod Autoscaler (HPA) is enabled
	•	metrics-server is installed to feed metrics to the HPA
	•	Pods auto-scale based on CPU/memory usage

## 🎥 Demo

🚧 Coming soon: A full demo video showcasing setup, deployment, scaling, monitoring, and GitOps flow.
