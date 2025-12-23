# ☁️ Cloud Message Board (AWS ECS Fargate)

A Full-Stack, containerized 3-tier application deployed on AWS using Infrastructure as Code (Terraform). 

This project demonstrates a **Cloud-Native workflow**: containerizing a Node.js application, pushing it to an AWS Registry (ECR), and orchestrating it via ECS Fargate with a persistent RDS MySQL database backend.

---

## 🏗️ Architecture
This project utilizes a **Cost-Optimized 3-Tier Architecture** designed to run in a real AWS environment while minimizing infrastructure overhead.

* **Tier 1 (Traffic):** Public-facing Application Load Balancer (ALB) handles ingress traffic and performs health checks.
* **Tier 2 (Compute):** AWS ECS (Fargate) runs the stateless Node.js containers. It is configured for zero-maintenance serverless compute.
* **Tier 3 (Data):** AWS RDS (MySQL) provides persistent storage. The database is secured via Security Group chaining (only the App Tier can access port 3306).

### 🛠️ Tech Stack
* **Application:** Node.js (Express), MySQL2
* **Infrastructure:** Terraform (Modular Design)
* **Containerization:** Docker & AWS ECR
* **Cloud Provider:** AWS (ECS, Fargate, RDS, VPC, IAM)

---

## ⚠️ Cost Warning (Paid Resources)
This project deploys **real enterprise-grade infrastructure**, not just free-tier resources. If you deploy this, you will incur costs on your AWS bill:

* **Application Load Balancer (ALB):** ~$0.0225 per hour (~$16/month).
* **AWS Fargate:** Charged per vCPU/Memory minute while running.
* **RDS MySQL:** Free Tier eligible (if applicable), otherwise standard hourly rates.

**Recommendation:** Run `terraform destroy` immediately after testing to stop the billing clock.

---

## 🚀 Key Features
* **Self-Healing Infrastructure:** The ALB monitors container health. If the application crashes or becomes unresponsive, ECS automatically replaces the failed task.
* **Automated Database Migration:** No manual SQL scripts required. The application detects a fresh database on startup and automatically injects the required schema and tables.
* **Infrastructure as Code (IaC):** The entire environment (VPC, Security Groups, IAM Roles, Database, Compute) is defined in Terraform modules.
* **Zero-Downtime Updates:** The architecture supports rolling updates.

---

## ⚙️ How to Deploy

### Prerequisites
* AWS CLI (Configured with credentials)
* Terraform
* Docker (Running locally)
### Step 1: Build & Push Image


### Step 1: Build & Push Image
Run these commands inside the `cloud-message-board` folder to package the app and send it to AWS ECR.

```bash
cd cloud-message-board

# 1. Login to ECR (Replace with your Region/Account ID)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# 2. Build the Docker Image (For Linux/AMD64 architecture)
docker build --platform linux/amd64 -t cloud-message-board .

# 3. Tag and Push (Replace <YOUR_REPO_URL> with your ECR URL)
docker tag cloud-message-board:latest <YOUR_REPO_URL>:v5
docker push <YOUR_REPO_URL>:v5
```
### Step 2: Deploy the infrastructure
Run these commands inside the infrastructure folder to build the AWS environment.

```
cd infrastructure
# 1. Initialize Terraform
terraform init

# 2. Apply the configuration
terraform apply --auto-approve
```
### Step 3: Access the App
```
terraform output load_balancer_url
Copy the URL (e.g., http://ecs-alb-12345.us-east-1.elb.amazonaws.com).
Paste it into your browser to verify the application is running.
```

Clean Up
To avoid ongoing AWS charges, destroy the infrastructure when finished:
```
cd infrastructure
terraform destroy --auto-approve
