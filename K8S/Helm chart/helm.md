# Helm Chart and Kubernetes: Quick Guide

## 1. What is a Helm Chart?

A **Helm Chart** is a collection of files that describe a set of Kubernetes resources. Helm is a package manager for Kubernetes, and a Helm Chart is the packaging format it uses. Helm Charts simplify the deployment, scaling, and management of applications in a Kubernetes cluster by allowing you to define, version, and share Kubernetes application configurations in a standardized way.
 **![Image](https://github.com/user-attachments/assets/408d8941-31a2-4f5e-a531-4286cea5b3a9)**

## 2. Why Do We Need Kubernetes?

Kubernetes (K8s) is essential for modern containerized application management because:

- **Scalability**: Easily scale applications to handle millions of requests.
- **Automated Deployment**: Automates the deployment and management of Docker containers.
- **Auto-Healing**: Automatically replaces unhealthy containers to maintain application health.
- **Rollout & Rollback**: Supports seamless updates (rollouts) and quick reversion (rollbacks) to previous versions if issues occur.

## 3. How Does a Helm Chart Help Manage Kubernetes?

Helm Charts help manage Kubernetes by:

- **Packaging**: Bundle all Kubernetes resources (Deployments, Services, ConfigMaps, etc.) into a single, reusable chart.
- **Templating**: Use variables and templates to customize deployments for different environments without duplicating YAML files.
- **Versioning**: Track and manage different versions of your applications, making rollbacks and upgrades easy.
- **Dependency Management**: Define and manage dependencies between charts, enabling modular and scalable application architectures.
- **Release Management**: Install, upgrade, rollback, and uninstall applications with simple Helm commands, streamlining the deployment process.

**![Image](https://github.com/user-attachments/assets/d066287d-5350-41bc-9808-a6a8a9af7ab3)**

## 4. Installing a Helm Chart: Step-by-Step

### Pre-requisites

- A running Kubernetes cluster. You can use:
    - **EKS**: Amazon Elastic Kubernetes Service
    - **GKE**: Google Kubernetes Engine
    - **AKS**: Azure Kubernetes Service
    - **microk8s**: Lightweight Kubernetes for local development (used in this demo)

### Setting Up microk8s on Ubuntu

Follow the [microk8s documentation](https://microk8s.io/docs/getting-started):

```bash
sudo apt update -y
sudo snap install microk8s --classic --channel=1.31
```

Add your user to the `microk8s` group:

```bash
sudo usermod -a -G microk8s $USER
```

Set up your kube config directory:

```bash
mkdir -p ~/.kube
chmod 0700 ~/.kube
```

Activate the new group:

```bash
newgrp microk8s
# or
su - $USER
```

Export microk8s config:

```bash
microk8s config > ~/.kube/config
sudo chown -R $USER ~/.kube
ls -l ~/.kube/config
```

Check microk8s status:

```bash
microk8s status --wait-ready
```

### Install kubectl

```bash
sudo snap install kubectl --classic
```
Or follow the [official documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux).

To use kubectl with microk8s:

```bash
microk8s kubectl get services
alias kubectl='microk8s kubectl'
kubectl get all --all-namespaces
```
### Check Your Kubernetes Context

Before installing a Helm chart, ensure you are connected to the correct Kubernetes cluster by checking your current context:

```bash
kubectl config current-context
```

This command will display the name of the current context, confirming which cluster your `kubectl` and Helm commands will target. If you need to switch contexts, use:

```bash
kubectl config use-context <context-name>
```
---

## References

- [Helm Documentation](https://helm.sh/docs/)
- [microk8s Documentation](https://microk8s.io/docs/getting-started)
- [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux)

# Writing your first Helm3 Chart for "Hello World"

Now after you have done your Helm3 Chart installation, we can write our first "Hello World" Helm3 Chart.

To begin with -

---

## 2.1: Create your first Helm3 Chart

We are going to create our first helloworld Helm3 Chart using the following command:

```bash
helm3 create helloworld
```

It should create a directory `helloworld`, you can verify it by using the following command:

```bash
ls -lart | grep helloworld
```

It should return you with:

```bash
drwxr-xr-x 4 vagrant vagrant     4096 Nov  7 19:57 helloworld
```

To verify the complete directory structure of the Helm3 Chart, run:

```bash
tree helloworld
```

Expected output:

```
helloworld
├── charts
├── Chart.yaml
├── templates
│  ├── deployment.yaml
│  ├── _helpers.tpl
│  ├── hpa.yaml
│  ├── ingress.yaml
│  ├── NOTES.txt
│  ├── serviceaccount.yaml
│  ├── service.yaml
│  └── tests
│      └── test-connection.yaml
└── values.yaml
```

Great, now you created your first Helm3 Chart - `helloworld`.

---

## 2.2: Update the service.type from ClusterIP to NodePort inside the values.yaml

Before you run your helloworld Helm3 Chart, update the `service.type` from `ClusterIP` to `NodePort`.

The reason for this change is: After installing/running the helloworld Helm3 Chart, you should be able to access the service outside of the Kubernetes cluster. If you do not change the `service.type`, you will only be able to access the service within the Kubernetes cluster.

First, go inside the directory `helloworld`:

```bash
cd helloworld
```

### 2.2.1: Open values.yaml in vi

Open the `values.yaml` in `vi`:

```bash
vi values.yaml
```

### 2.2.2: Update service.type from ClusterIP to NodePort

Look for the `service.type` block and update its value to `NodePort`:

```yaml
service:
    type: NodePort
    port: 80
```

---

## 2.3: Install the Helm3 Chart using command - helm3 install

Now after updating the `values.yaml`, you can install the Helm3 Chart.

**Note:** The `helm3 install` command takes two arguments:

- First argument: Release name that you pick
- Second argument: Chart you want to install

It should look like:

```bash
helm3 install <RELEASE_NAME> <CHART_NAME>
```

Your final command would be:

```bash
microk8s config > ~/.kube/config
helm3 install myhelloworld helloworld 
or 
microk8s helm3 install myhelloworld helloworld

```

After running the above command, it should return you with:

```
NAME: myhelloworld
LAST DEPLOYED: Sat Nov  7 21:48:08 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
    export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services myhelloworld-helloworld)
    export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
    echo http://$NODE_IP:$NODE_PORT
```

---

## 2.4: Verify the helm3 install command

Now verify your helm3 release (`myhelloworld`) by running:

```bash
microk8s helm3 list -a
```

It should return you with the release name you have just installed:

```
NAME           NAMESPACE  REVISION  UPDATED                               STATUS    CHART            APP VERSION
myhelloworld   default    1         2020-11-07 21:48:08.8550677 +0000 UTC deployed  helloworld-0.1.0 1.16.0
```

---

## 2.5: Get Kubernetes Service details and port

Run the following command to get the NodePort:

```bash
kubectl get service
```

Expected output:

```
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes               ClusterIP   10.233.0.1      <none>        443/TCP        14d
myhelloworld-helloworld  NodePort    10.233.14.134   <none>        80:30738/TCP   7m10s
```

**Note:** The NodePort number can vary in the range 30000-32767, so you might get a different NodePort.

Since the cluster IP is `100.0.0.2` and NodePort is `30738`, you can access your Nginx page of your `myhelloworld` Helm3 Chart.

---

**Helm3 chart: helloworld**

## 2.6: Accessing Your Application in the Browser

To access your deployed application from your browser, you need the **Node IP** and the **NodePort**.

1. **Get the Node IP**  
    Run the following command on your VM to get the IP address:
    ```bash
    hostname -I
    ```
    Example output:
    ```
    172.30.159.60 172.17.0.1 10.1.124.0
    ```
    Use the first IP (`172.30.159.60`) as your Node IP.



3. **Access in Browser**  
    Open your browser and navigate to:
    ```
    http://<NodeIP>:<NodePort>
    ```
    For the example above:
    ```
    http://172.30.159.60:30738
    ```

---
## 2.7: Accessing the Kubernetes Dashboard with microk8s

microk8s provides a built-in Kubernetes Dashboard for cluster management and visualization.

### 2.7.1: Enable the Dashboard

If not already enabled, run:

```bash
microk8s enable dashboard
```

### 2.7.2: Start the Dashboard Proxy

Start the proxy to access the dashboard:

```bash
microk8s dashboard-proxy
```

You will see output similar to:

```
Dashboard will be available at https://127.0.0.1:10443
Use the following token to login:
<your-token>
```

### 2.7.3: Access the Dashboard

1. Open your browser and go to:  
    ```
    https://127.0.0.1:10443
    ```
2. Ignore any browser security warnings (self-signed certificate).
3. Copy the provided token from the terminal and paste it into the Dashboard login page.

You now have access to the Kubernetes Dashboard for managing your cluster resources visually.
**![Image](https://github.com/user-attachments/assets/ac22d5ce-ac50-4db8-9eb6-74c332d8e21d)**

---

![Image](https://github.com/user-attachments/assets/587258fb-874b-43dc-9b52-24e3fe0eeefe)
--- 
## 2.8: Uninstalling a Helm3 Release

To remove a deployed Helm3 release, use the `helm3 uninstall` command followed by the release name. For example:

```bash
microk8s helm3 uninstall myhelloworld
```

You should see output confirming the release has been uninstalled:

```
release "myhelloworld" uninstalled
```

After uninstalling, you can verify that the resources have been removed by running:

```bash
kubectl get all
```

Expected output (only the default Kubernetes service remains):

```
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   65m
```

This confirms that your Helm3 release and its associated resources have been successfully deleted from the cluster.