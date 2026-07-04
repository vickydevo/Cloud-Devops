# Testing ClusterIP Services in Kubernetes

ClusterIP services in Kubernetes are accessible only within the cluster. This guide outlines two methods to test a ClusterIP service without relying on port-forwarding.

---

## Kubernetes Deployment and Service Configuration

### Deployment Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
   name: springboot-deployment
   labels:
      app: spring
spec:
   replicas: 3
   selector:
      matchLabels:
         app: spring
   template:
      metadata:
         labels:
            app: spring
      spec:
         containers:
         - name: springboot
            image: vignan91/spring-test:30aug
            ports:
            - containerPort: 8081
```

### Service Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
   name: spring-service
   labels:
      app: spring
spec:
   type: ClusterIP
   selector:
      app: spring
   ports:
      - protocol: TCP
         port: 8081
         targetPort: 8081
```

---

## Methods to Test ClusterIP Services

### 1. Using an Existing Pod

If you have a pod with utilities like `curl` or `wget`, you can directly use it to test the service.

### 2. Executing into a Pod and Testing the Service

If no utility pod is available, you can exec into an existing pod and use `curl` to test the service.

#### Steps:

1. Exec into a running pod:

    ```bash
    kubectl exec -it <pod-name> -- bash
    ```

    Example:

    ```bash
    kubectl exec -it springboot-deployment-67fbd7cdfd-2kb7m -- bash
    ```

2. Inside the pod, test the service:

    ```bash
    curl http://spring-service:8081
    ```

This confirms whether the service is accessible and discoverable within the cluster.