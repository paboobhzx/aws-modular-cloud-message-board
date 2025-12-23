# ☁️ Cloud Message Board (App)

![Node.js](https://img.shields.io/badge/Backend-Node.js-green)
![Docker](https://img.shields.io/badge/Container-Docker-blue)
![Database](https://img.shields.io/badge/DB-MySQL-orange)

A **Cloud-Native** web application built to demonstrate resilience and "Twelve-Factor App" methodologies in containerized environments.

Unlike traditional apps, this application is **"Infrastructure-Aware"**—it knows how to handle volatile cloud lifecycles, cold starts, and database connection interruptions gracefully.

---

## 🧠 Smart Features
This project solves specific cloud engineering challenges:

### 1. 🛡️ Self-Healing Database Connections
In the cloud, the database might not be ready when the app starts.
* **Standard App:** Crashes immediately if the DB is offline.
* **This App:** Implements **Exponential Backoff**. It retries the connection (1s, 2s, 4s, 8s...) until the database is ready, preventing "CrashLoopBackOff" errors in ECS/Kubernetes.

### 2. 🔄 Auto-Migration (Schema-on-Boot)
Eliminates the need for manual SQL scripts or separate migration tools.
* On startup, the app checks if the table exists.
* If not, it automatically injects the Schema and Seed Data.
* This makes deployments **stateless** and **idempotent**.

### 3. 💓 Health Check Endpoint
Exposes a dedicated `/health` route.
* Used by **AWS Application Load Balancers (ALB)** to verify if the container is ready to accept traffic.
* Prevents zero-downtime deployments from routing users to dead containers.

### 4. 🛑 Graceful Shutdown
Handles `SIGINT` and `SIGTERM` signals from the orchestrator (ECS) to close database connections cleanly before the container is destroyed.

---

## 🛠️ Tech Stack
* **Runtime:** Node.js (Express)
* **Database:** MySQL2 (Promise wrapper)
* **Containerization:** Docker (Multi-stage builds)
* **Architecture:** MVC (Model-View-Controller)

---

## 🚀 How to Run Locally

### Option 1: With Docker (Recommended)
You can run this container locally if you have a MySQL instance running (or use Docker Compose).

```bash
# 1. Build the image
docker build -t message-board .

# 2. Run (Requires a running MySQL instance or env vars)
# Replace 'host.docker.internal' with your DB IP if not using Docker Desktop
docker run -p 3000:3000 \
  -e DB_HOST=host.docker.internal \
  -e DB_USER=root \
  -e DB_PASSWORD=my-secret-pw \
  message-board
```
📦 API Endpoints
GET	/	Renders the Message Board UI (HTML)
GET	/health	Returns 200 OK (For Load Balancers)
GET	/api/posts	JSON list of all messages
POST	/api/posts	Create a new message
