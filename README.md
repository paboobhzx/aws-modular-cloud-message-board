# Modular AWS Cloud Infrastructure ("The Cloud Message Board")

## 🚀 Project Overview
A fully modular Terraform project that deploys a secure, self-healing web application on AWS. It demonstrates **Infrastructure as Code (IaC)** best practices, including custom networking, least-privilege IAM roles, and private connectivity strategies.

I built this project to move beyond "Hello World" tutorials and simulate a real-world platform engineering environment. I refactored a monolithic Terraform configuration into reusable modules (`networking`, `compute`, `database`, `storage`) to ensure scalability and maintainability.

The application is a dynamic "Message Board" where EC2 instances fetch data from a **DynamoDB** table and display it on a webpage.

## 🏗 Architecture Highlights

### 1. Secure Networking
* **VPC Gateway Endpoint:** Connects EC2 instances to DynamoDB privately. Database traffic stays within the AWS internal network and never traverses the public internet, reducing latency and exposure.
* **Custom VPC:** Deployed with public subnets and strict routing tables.

### 2. Zero-Trust Security
* **IAM Roles (Least Privilege):** No hardcoded AWS credentials (access keys) are used.
* **Granular Permissions:** Instances assume an IAM Role that grants permission *only* to read specific DynamoDB tables and modify their own tags.

### 3. Self-Healing Compute
* **Auto Scaling Group (ASG):** Monitors instance health and automatically provisions replacements if a server fails.
* **Launch Templates:** Defines the "Golden Image" configuration for all web servers.

### 4. Dynamic Bootstrapping
* **IMDSv2 Integration:** A custom `user_data` script interacts with the EC2 Instance Metadata Service (Version 2) to fetch instance details secureley.
* **Self-Tagging:** Instances dynamically rename themselves (e.g., `Portfolio-Web-i-0abc...`) upon launch for easier observability.

## 🛠 Technical Stack

| Component | Technology |
| :--- | :--- |
| **IaC** | Terraform (Modular) |
| **Cloud Provider** | AWS (us-east-1) |
| **Compute** | EC2, ASG, Launch Templates |
| **Database** | DynamoDB (Serverless, NoSQL) |
| **Networking** | VPC, Route Tables, Gateway Endpoints |
| **Storage** | S3 (Versioning Enabled) |

## 💻 How to Deploy

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/paboobhzx/aws-modular-cloud-message-board.git](https://github.com/paboobhzx/aws-modular-cloud-message-board.git)
    ```
    *(Note: Update URL if you renamed the repo)*

2.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

3.  **Review the Plan:**
    ```bash
    terraform plan
    ```

4.  **Deploy:**
    ```bash
    terraform apply --auto-approve
    ```

5.  **Verify:**
    Access the web server using the Public IP from the AWS Console to see the message served securely from DynamoDB.