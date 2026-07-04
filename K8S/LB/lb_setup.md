


# EKS Spring Boot Deployment with Classic Load Balancer (CLB) Access

This guide outlines the steps and configuration required to deploy a Spring Boot application to an Amazon EKS cluster and expose it publicly using a Kubernetes **Service** of type `LoadBalancer`, which provisions an AWS Classic Load Balancer (CLB).

---

## 1. Kubernetes Deployment and Service YAML

The following YAML (`spring-lb-deployment.yml`) defines a Deployment for your Spring Boot application and a LoadBalancer Service to expose it.

**Note:** The ports are set for external access on `8082` and internal container port `8081`. The `nodePort` is included here for clarity, though Kubernetes usually assigns it automatically.


````markdown

# --- Deployment: Defines the desired state for your application's Pods
apiVersion: apps/v1
kind: Deployment
metadata:
  name: springboot-deployment-lb
  labels:
    app: spring-lb
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spring-lb
  template:
    metadata:
      labels:
        app: spring-lb
    spec:
      containers:
      - name: springboot
        image: vignan91/spring-test:30aug
        ports:
        - containerPort: 8081 # The port the Spring application listens on
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
# --- Service: Exposes the Deployment using an AWS Load Balancer
apiVersion: v1
kind: Service
metadata:
  name: spring-svc-lb
  labels:
    app: spring-lb
spec:
  # Type: LoadBalancer provisions an AWS Classic Load Balancer (CLB)
  type: LoadBalancer 
  selector:
    app: spring-lb
  ports:
    # 1. External Access Port
    - protocol: TCP
      port: 8082         # The CLB Listener Port (Public Access Port)
      targetPort: 8081   # The Pod/Container Port
      nodePort: 30262    # The NodePort (Used internally by the CLB)
````

-----

## 2\. Deployment Steps

Use `kubectl` to apply the YAML file to your EKS cluster:

```bash
# 1. Apply the Deployment and Service YAML
kubectl apply -f spring-lb-deployment.yml

# 2. Verify Pod status
kubectl get pods -l app=spring-lb

# 3. Monitor the Service status
# The EXTERNAL-IP will start showing the CLB DNS name once provisioned.
kubectl get svc spring-svc-lb --watch
```

**Note:** Provisioning the CLB typically takes 2-5 minutes.

-----

## 3\. Understanding the Traffic Flow and Ports

The three ports work together to route traffic from the public internet into your Pods. This is the core concept of the LoadBalancer Service type:

| Port in YAML | Value | Role in Traffic Flow |
| :--- | :--- | :--- |
| **`port`** | `8082` | **Public CLB Listener Port:** The port the external load balancer listens on for client connections. |
| **`nodePort`** | `30262` | **Internal CLB Target Port:** The random, high-numbered port on the worker node that the CLB uses to send traffic to. This port is *private* to the CLB and should **not** be used in the browser. |
| **`targetPort`**| `8081` | **Container Port:** The port your Spring Boot application is listening on inside the Pod. |

### Traffic Path Diagram

1.  **Client $\to$ CLB:** Your browser connects to the CLB's DNS name on **Port 8082**.
2.  **CLB $\to$ Node:** The CLB listener on Port 8082 forwards the request to the target worker node on **NodePort 30262**.
3.  **Node $\to$ Pod:** The worker node's `kube-proxy` component redirects traffic arriving on Port 30262 to your application Pod on **TargetPort 8081**.

-----

## 4\. Accessing the Application

Once the service shows an `EXTERNAL-IP` (which will be the CLB's DNS name), use the **Service Port** (`8082`) in the URL.

### 4.1 Get the CLB Endpoint

Wait until the `EXTERNAL-IP` field populates (it will contain the CLB DNS name):

```bash
kubectl get svc spring-svc-lb
```

**Example Output:**

```
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                                                    PORT(S)           AGE
spring-svc-lb   LoadBalancer   10.100.20.101   a668c8a3ae32c49ffc712a9f021f9-519641164.us-east-1.elb.amazonaws.com   8082:30262/TCP    2m
```

### 4.2 Construct the Access URL

Combine the `EXTERNAL-IP` with the **Service Port (`8082`)**:

```
# Access URL: [CLB_DNS_NAME]:[SERVICE_PORT]
http://a668c8a3ae32c41d49ffc712a9f021f9-519641164.us-east-1.elb.amazonaws.com:8082/
```

### 4.3 Troubleshooting Access

If you cannot access the application, the problem is usually an AWS firewall rule:

1.  **CLB Security Group:** Ensure the **CLB's Security Group** (found in the AWS EC2 Console) has an **Inbound Rule** allowing traffic on **Port 8082** from `0.0.0.0/0`.
2.  **Node Security Group:** The EKS control plane automatically configures the worker node security group to allow traffic on the **NodePort (30262)** from the CLB, but it's always good to verify this internal communication is not blocked.

**Remember:** Never use the `nodePort` (e.g., `30262`) in the public URL with the Load Balancer DNS name, as the CLB is not listening on that port.

```
