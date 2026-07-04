# Exposing and Accessing Your Application Externally

This guide explains how to expose your Kubernetes application externally using a NodePort service and how to access it from outside the cluster. In this example, the application is deployed on an EC2 instance and uses a NodePort service to expose the app.

---

## Prerequisites

- **Kubernetes Cluster:** Ensure you have a running Kubernetes cluster (e.g., on an EC2 instance).
- **Deployment & NodePort Service:** Your application is deployed with a Deployment and exposed via a NodePort Service.
- **YAML Configuration:** The NodePort service is configured to use:
  - **Service Port:** `8082`
  - **Container Port:** `8081`
  - **NodePort:** `30037`
- **External Access:** Your EC2 instance (or Kubernetes node) has a public IP address, and necessary firewall rules/security groups allow traffic on port `30037`.

---

## Step 1: Verify the NodePort Service

1. **List Services:**

   Run the following command to ensure your NodePort service is deployed:
   ```bash
   kubectl get svc

## 2. Check for Your Service:

You should see an output similar to:

```
NAME             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
spring-svc-np    NodePort   10.101.40.189   <none>        8081:30037/TCP   5m
```

## Minikube Specifics:

When using minikube, the cluster’s internal IP (10.106.252.54) isn’t reachable from outside. Instead, run:
---

## Deploying an Application with NodePort Service

To deploy an application using a manifest file with a NodePort service and access it in your browser, follow these steps:

### 1. Create the Manifest File

Create a manifest file (e.g., `nodeport-service.yml`) with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30037
```

### 2. Apply the Manifest

```bash
kubectl apply -f nodeport-service.yml
```

![Image](https://github.com/user-attachments/assets/2ba8953c-665a-449d-87bd-a3cef5167e29)

### 3. Verify Deployment and Service

```bash
kubectl get deployments
kubectl get services
```

### 4. Access the Application

- Use the Minikube IP:

  ```bash
  minikube ip
  ```

- On your EC2 instance, access the service:

  ```bash
  curl http://<minikube-ip>:30037
  ```

![Image](https://github.com/user-attachments/assets/502b37a2-beb0-4a48-96be-1c8b76bdd597)

You should see the default Nginx welcome page.

---

## Step 1: Access NodePort Service on EC2 Instance

Since Minikube is running inside an EC2 instance, the NodePort service won't be directly accessible via the EC2 public IP. Follow these steps to access the service:

1. **Enable Port Forwarding on Minikube**

   ```bash
   kubectl port-forward service/my-app-service 8080:80
   ```

   ![Image](https://github.com/user-attachments/assets/f0f8c1a0-9007-4b27-bced-e4131f508468)

2. **Access the Service Locally on EC2**

   ```bash
   curl http://localhost:8080
   ```

   ![Image](https://github.com/user-attachments/assets/1f54873e-b4fd-48b2-9088-a033a9f45cb6)

3. **Access the Service Externally**

   Set up an SSH tunnel from your local machine to the EC2 instance:

   ```bash
   ssh -i <your-key.pem> -L 8081:localhost:8080 ec2-user@<your-ec2-public-ip>
   ```

   ![Image](https://github.com/user-attachments/assets/4dbf90a6-59c7-475d-98d5-634610d3d996)

   Then, open your browser and navigate to:

   ```
   http://localhost:8081
   ```

   ![Image](https://github.com/user-attachments/assets/a6b8af38-f041-44ce-895b-09e782d14dce)

This setup allows you to access the NodePort service running inside Minikube on the EC2 instance from your local machine.

---

## Step 2: Access NodePort Service Using Minikube Tunnel

Alternatively, you can expose the NodePort service using an SSH tunnel directly to the Minikube IP:

1. **Set Up an SSH Tunnel**

   ```bash
   ssh -i private.pem -L 8081:192.168.49.2:30037 ubuntu@54.161.50.57
   ```

   ![Image](https://github.com/user-attachments/assets/999c525f-6791-4e51-a4b8-6e8c5a24db54)

2. **Access the Service Locally**

   ```bash
   curl http://localhost:8081
   ```

This method allows you to directly access the NodePort service running inside Minikube from your local machine without additional port forwarding steps.

---

## Request Workflow: Browser to NGINX Container

The following diagram illustrates the request workflow from your local browser to the NGINX container running inside Kubernetes on Minikube:

```
Browser (local machine)
  ↓
localhost:8081
  ↓ (via SSH tunnel)
EC2 instance 8080
  ↓
Minikube IP 192.168.49.2:30037
  ↓
NGINX container inside Kubernetes
```

This setup ensures secure access to the NodePort service running inside Minikube from your local machine.
