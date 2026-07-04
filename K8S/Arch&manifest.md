# Kubernetes Overview

## What is Kubernetes?
Kubernetes, also known as "K8s", is an open-source container orchestration platform developed by Google. It is designed to automate the deployment, scaling, and management of containerized applications across a cluster of nodes. Kubernetes provides a consistent and reliable way to manage applications, whether they are running on-premises, in the cloud, or in hybrid environments.

## Why Kubernetes?
Kubernetes exists to manage containerized applications at scale, providing automation, scalability, and resilience. It addresses several challenges that arise when running containers in production:

1. **Automated Deployment & Scaling**  
   - Kubernetes automates rolling updates and rollbacks.
   - It can scale applications up or down based on demand (e.g., CPU/memory usage).

2. **Load Balancing & Traffic Management**  
   - Kubernetes distributes network traffic to ensure stable application performance.

3. **Self-Healing & Fault Tolerance**  
   - If a container crashes, Kubernetes automatically restarts it.
   - If a node fails, Kubernetes shifts workloads to healthy nodes.

4. **Resource Optimization**  
   - Kubernetes efficiently schedules workloads to maximize resource utilization.
   - It optimizes CPU and memory usage across multiple applications.

5. **Service Discovery & Networking**  
   - Kubernetes provides built-in DNS-based service discovery.
   - Services can communicate with each other using stable network addresses.

6. **Portability & Flexibility**  
   - Kubernetes is cloud-agnostic and works on **AWS, Azure, GCP, on-premises, and hybrid environments**.
   - It supports multiple container runtimes (Docker, containerd, CRI-O).

7. **Security & Configuration Management**  
   - Kubernetes manages sensitive data using **Secrets**.
   - It isolates workloads for better security.

## What is Microservices?
Microservices is an architectural pattern where an application is structured as a collection of small, independently deployable services. Each service performs a specific function and communicates with other services over well-defined APIs.

# Architecture & Components of Kubernetes
![Image](https://github.com/user-attachments/assets/9643419f-cb37-46ac-a3c0-3459efb5b338)

## Master Node Components

### 1. **API Server**
The API server is the front end of the Kubernetes control plane. It exposes the Kubernetes API and handles requests from users and other components.

### 2. **Scheduler**
The scheduler assigns pods to nodes based on resource availability and other factors.

### 3. **Controller Manager**
The controller manager ensures the desired state of resources is maintained. Some important controllers are:
- **Node Controller**: Monitors node health.
- **Replication Controller**: Ensures the desired number of pods are running.
- **Endpoint Controller**: Manages services and their endpoints.
- **Job Controller**: Manages one-off tasks.
- **DaemonSet Controller**: Ensures a pod runs on all or specified nodes.

### 4. **etcd Database**
A consistent and highly-available key-value store used as the backing store for all cluster data.

## Worker Node Components

### 1. **Kubelet**
An agent running on each node, ensuring containers are running as specified in a Pod.

### 2. **Kube-proxy**
A network proxy that maintains network rules for pods and handles communication between services and pods.

---

# Kubernetes Workload Components

## Pods
A Pod is the smallest deployable unit in Kubernetes and can contain one or more containers. Pods are managed by higher-level objects like Deployments and ReplicaSets.

### Example Pod Manifest:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx:latest
    ports:
    - containerPort: 8080
```

## Deployments
A Deployment is an object that manages a set of Replica Pods, allowing for declarative updates and scaling.

### Example Deployment Manifest:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: nginx:latest
        ports:
        - containerPort: 8080
```

## ReplicaSets
A ReplicaSet ensures that a specified number of replica Pods are running at any given time.

### Example ReplicaSet Manifest:
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: nginx:latest
        ports:
        - containerPort: 8080
```

# Kubernetes Services

## ClusterIP
The default service type that exposes the service on a cluster-internal IP, making it reachable only from within the cluster.

### Example ClusterIP Service Manifest:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-cip
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: my-app-cip
```

## NodePort
Exposes the service on each node’s IP at a static port. This makes the service accessible from outside the cluster.

### Example NodePort Service Manifest:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-np
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: my-app-np
```

## LoadBalancer
Exposes the service externally using a cloud provider’s load balancer. Automatically creates a NodePort and ClusterIP service.

### Example LoadBalancer Service Manifest:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-lb
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: my-app-lb
```



# Labels and Selectors

## Labels
Labels are key-value pairs that are attached to Kubernetes objects to provide identifying metadata. They are useful for grouping and selecting resources.

### Example of Labels:
```yaml
labels:
  app: guestbook
  tier: frontend
```

## matchLabels in Selector
The matchLabels field is used to select pods for ReplicaSets based on labels.

### Example:
```yaml
selector:
  matchLabels:
    tier: frontend
```
This ensures that only pods with the `tier: frontend` label are selected.

# Common Questions

### 1. Is Docker mandatory for Kubernetes?
Kubernetes requires container technologies to orchestrate, but Docker is not mandatory. It supports other container runtimes as well.

### 2. How is Kubernetes different from Docker?
Docker is primarily a container runtime, while Kubernetes is a container orchestration platform. Kubernetes manages the deployment, scaling, and operation of containers across multiple hosts, whereas Docker is used to build and run individual containers.

### 3. Is Kubernetes open-source or commercial?
Kubernetes is completely open-source and free to use.

### 4. What problems does Kubernetes solve?
Kubernetes manages multiple Docker hosts/nodes under a cluster, scales and automates container management, and ensures high availability of applications.

### 5. What benefits does Kubernetes bring?
Kubernetes provides a modular-based structure for managing containerized applications, which includes auto-scaling, rolling updates, load balancing, and self-healing capabilities.

### 6. Are there any Kubernetes alternatives?
Yes, alternatives include OpenShift, Docker Swarm, and others.

### 7. What about Azure Kubernetes Service (AKS), AWS Kubernetes Service (EKS), and Google Kubernetes Engine (GKE)?
These are cloud-managed services for Kubernetes, providing managed environments for running Kubernetes clusters.