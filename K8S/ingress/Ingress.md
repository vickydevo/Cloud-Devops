# Kubernetes Ingress: Overview and Comparison with LoadBalancer

## What is Ingress?

**Ingress** is a Kubernetes API object that manages external access to services within a cluster, typically HTTP and HTTPS traffic. It acts as an application layer (Layer 7) load balancer, enabling advanced routing and centralized management of incoming requests.

## What is an Ingress Controller?

An **Ingress Controller** is a component that implements the Ingress resource. It listens for changes to Ingress resources and configures the underlying load balancer or reverse proxy (such as NGINX, Traefik, or cloud-native controllers) to route external traffic according to the defined rules.

## What is an Ingress Resource?

An **Ingress Resource** is a Kubernetes object where you define routing rules for external traffic. These rules can include:

- **Path-based routing:** Direct traffic to different services based on URL paths (e.g., `/api` vs `/web`).
- **Host-based routing:** Route traffic based on hostnames (e.g., `app1.example.com` vs `app2.example.com`).
- **TLS termination:** Secure traffic using SSL/TLS certificates.

The Ingress Controller reads these rules and enforces them at the cluster edge.

## Quick Summary

- **Ingress** = Traffic routing rules + external access to services.
- **Ingress Resource (YAML):** The Kubernetes object where you define rules for routing external HTTP/S traffic (hosts, paths, backends/services).
- **Ingress Controller:** The actual component (like NGINX, Traefik, or others) running inside the cluster that listens to those Ingress resource rules and implements the traffic routing.

**![Image](https://github.com/user-attachments/assets/dfbec2ae-26eb-4e83-9fa7-fe83c0b3be32)**



## Ingress vs LoadBalancer Service

| Feature                | Ingress                                   | LoadBalancer Service                  |
|------------------------|-------------------------------------------|---------------------------------------|
| Layer                  | 7 (HTTP/HTTPS, application)               | 4 (TCP/UDP, transport)                |
| Routing                | Path/host-based, advanced rules           | Direct to service, no routing logic   |
| TLS Termination        | Supported                                 | Supported (per service)               |
| Cost                   | One controller for many services          | One load balancer per service         |
| Use Case               | Centralized, flexible traffic management  | Simple, direct external access        |

**Summary:**  
- Use **Ingress** for advanced, centralized routing and cost-effective management of multiple services.
- Use **LoadBalancer Service** for simple, direct access to a single service.


## Installing an Ingress Controller in MicroK8s

To enable and use an Ingress Controller in MicroK8s, follow these steps:

### 1. Enable the Ingress Add-on

MicroK8s provides a built-in NGINX Ingress Controller as an add-on. Enable it with:

```sh
microk8s enable ingress
```

### 2. Verify the Ingress Controller

Check that the Ingress Controller pod is running:

```sh
microk8s kubectl get pods -n ingress
```
### Alternative: Install the Official NGINX Ingress Controller

To install the official NGINX Ingress Controller (instead of the MicroK8s add-on), apply the following manifest:

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.1/deploy/static/provider/cloud/deploy.yaml
```

This will deploy the NGINX Ingress Controller using the recommended configuration from the Kubernetes project. For more details, refer to the [official documentation](https://kubernetes.github.io/ingress-nginx/deploy/).

You should see a pod named similar to `nginx-ingress-microk8s-controller` in the `Running` state.

### 3. Expose Services Using Ingress

Create an Ingress resource YAML file (e.g., `my-ingress.yaml`) and apply it:

```sh
microk8s kubectl apply -f my-ingress.yaml
``` 

## Example: Deploying Multiple Services and Ingress

Below are the commands to deploy multiple services and configure Ingress routing:

```sh
kubectl apply -f ingress/dep-spring.yaml
kubectl apply -f ingress/deploy-one.yaml
kubectl apply -f ingress/deploy-two.yaml
kubectl apply -f ingress/ingress_reso_path.yaml
kubectl port-forward --namespace ingress-nginx service/ingress-nginx-controller 9900:80
```

These commands will:
- Deploy a Spring Boot app, NGINX, and HTTPD as separate services.
- Create an Ingress resource for path-based routing.
- Forward port 9900 on your local machine to the Ingress Controller for testing. not cloud k8s
### 4. Accessing Ingress

By default, the Ingress Controller listens on the cluster node's IP address. You can access your services using the node IP and the configured paths or hostnames.
   http://127.0.0.1:8888/spring
---

For more details, see the [MicroK8s Ingress documentation](https://microk8s.io/docs/addon-ingress).