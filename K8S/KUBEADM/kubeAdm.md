Here is your updated, fully integrated `README.md` containing the entire installation guide alongside your newly verified validation tests for Calico CNI auto-detection.


# Kubernetes Cluster Installation Guide (v1.35)

This guide walks you through setting up a Kubernetes cluster using the **CRI-O** container runtime interface. The environment consists of one control-plane node (`manager01`) and two worker nodes (`node01`, `node02`).

All steps are optimized to be run by a **non-root user with `sudo` privileges**.

---

## 📋 Table of Contents
1. [Node Architecture & IP Matrix](#node-architecture--ip-matrix)
2. [Automated Node Provisioning (All Nodes)](#1-automated-node-provisioning-all-nodes)
3. [Control-Plane Initialization (manager01 Only)](#2-control-plane-initialization-manager01-only)
4. [Worker Node Configuration (node01 & node02 Only)](#3-worker-node-configuration-node01--node02-only)
5. [Cluster Verification Matrix](#4-cluster-verification-matrix)

---

## Node Architecture & IP Matrix

| Hostname | Role | IP Address |
| :--- | :--- | :--- |
| `manager01` | Control-Plane | `10.0.0.101` |
| `node01` | Worker Node | *(Assign IP)* |
| `node02` | Worker Node | *(Assign IP)* |

---

## 1. Automated Node Provisioning (All Nodes)

Execute this script on **ALL** nodes (`manager01`, `node01`, `node02`). It handles OS prep work, repository configurations, CRI-O engine deployment, and installations for `kubeadm`, `kubelet`, and `kubectl`.

### Create the Script
Create a file named `script.sh` on each machine:

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================================"
echo "  Starting Kubernetes v1.35 & CRI-O Bootstrap Script   "
echo "========================================================"
echo ""

# ==============================================================================
# 1. DISABLE SWAP
# ==============================================================================
echo "Disabling swap memory (required by Kubernetes)..."
sudo swapoff -a

echo "Modifying /etc/fstab to persist swap disablement across reboots..."
sudo sed -i '/swap/d' /etc/fstab
echo "[SUCCESS] Swap has been permanently disabled."
echo ""

# ==============================================================================
# 2. CONFIGURE KERNEL MODULES
# ==============================================================================
echo "Creating kernel module configuration file for Kubernetes networking..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF

echo "Loading 'overlay' and 'br_netfilter' modules into active memory..."
sudo modprobe overlay
sudo modprobe br_netfilter
echo "[SUCCESS] Kernel modules successfully loaded."
echo ""

# ==============================================================================
# 3. CONFIGURE SYSCTL PARAMETERS
# ==============================================================================
echo "Configuring sysctl parameters for bridged IPv4 traffic routing..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

echo "Applying new sysctl rules instantly without reboot..."
sudo sysctl --system > /dev/null
echo "[SUCCESS] Network routing parameters applied."
echo ""

# ==============================================================================
# 4. KEYRINGS DIRECTORY & ENVIRONMENT VARIABLES
# ==============================================================================
echo "Creating secure keyrings directory (/etc/apt/keyrings)..."
sudo mkdir -p -m 755 /etc/apt/keyrings

echo "Exporting Kubernetes and CRI-O versions (Target: v1.34)..."
export KUBERNETES_VERSION=v1.35
export CRIO_VERSION=v1.35
echo "[SUCCESS] Directory and version environment variables prepared."
echo ""

# ==============================================================================
# 5. CONFIGURE KUBERNETES APT REPOSITORY
# ==============================================================================
echo "Downloading official Kubernetes public GPG signing key..."
curl -fsSL "https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key" | \
    sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Adding Kubernetes apt repository source definition..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
echo "[SUCCESS] Kubernetes repository setup complete."
echo ""

# ==============================================================================
# 6. CONFIGURE CRI-O REPOSITORY
# ==============================================================================
echo "Downloading official CRI-O container runtime GPG signing key..."
curl -fsSL "https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key" | \
    sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "Adding CRI-O apt repository source definition..."
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" | \
    sudo tee /etc/apt/sources.list.d/cri-o.list > /dev/null
echo "[SUCCESS] CRI-O repository setup complete."
echo ""

# ==============================================================================
# 7. INSTALL RUNTIMES AND BINARIES
# ==============================================================================
echo "Updating package lists from newly added repositories..."
sudo apt-get update -y > /dev/null

echo "Installing CRI-O engine, kubelet, kubeadm, and kubectl (This may take a moment)..."
sudo apt-get install -y cri-o kubelet kubeadm kubectl

echo "Pinning package versions to prevent unintended upgrades breaking the cluster..."
sudo apt-mark hold kubelet kubeadm kubectl
echo "[SUCCESS] All binaries installed and held at current version."
echo ""

# ==============================================================================
# 8. ENABLE AND START SERVICES
# ==============================================================================
echo "Reloading systemd manager configuration..."
sudo systemctl daemon-reload

echo "Enabling and starting CRI-O container runtime service..."
sudo systemctl enable crio --now

echo "Enabling and bootstrapping the kubelet service..."
sudo systemctl enable kubelet --now
echo "[SUCCESS] CRI-O and Kubelet services are actively running."
echo ""

echo "========================================================"
echo "         Node Setup Complete! Ready for Cluster         "
echo "========================================================"

```

### Execution

Make the script executable and run it as a regular user (**do not** use `sudo ./script.sh`). The script prompts for passwords internally when needed:

```bash
chmod +x script.sh
./script.sh

```

---

## 2. Control-Plane Initialization (`manager01` Only)

### Pre-pull Container Images

Pull the required cluster control plane images beforehand to verify setup readiness:

```bash
sudo kubeadm config images pull

```

### Initialize Cluster

Run `kubeadm init` mapping out your target management interface IP and pod network space:

```bash
sudo kubeadm init \
  --apiserver-advertise-address=10.0.0.101 \
  --pod-network-cidr=172.17.0.0/16

```

> ⚠️ **Important:** Note down the exact `kubeadm join` terminal output string generated at the very end of this process. You will need it for the worker nodes.

### Configure Non-Root Local Administrative Access

Allow your local non-root user account to talk directly to the cluster API:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```

### Install Pod Networking (Calico CNI Plugin)

Apply the Tigera Calico network fabric policy manifests to manage internal cluster routing:

```bash
kubectl apply -f https://docs.tigera.io/calico/latest/manifests/calico.yaml

```

### Verify Calico Pod Network CIDR Auto-Detection

Calico automatically parses the active Kubernetes configuration parameters to identify your pod space. Run the following validation command on `manager01` to check the live `IPPool` resource metadata:

```bash
kubectl get ippools -o yaml

```

Verify that the `spec.cidr` definition automatically caught your initialization variable:

```yaml
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: default-ipv4-ippool
spec:
  cidr: 172.17.0.0/16      # <--- Confirms Calico auto-detected your Pod CIDR
  ipipMode: Always
  natOutgoing: true

```

---

## 3. Worker Node Configuration (`node01` & `node02` Only)

### Join the Cluster

Paste the generated cluster join command from your management server directly into your worker terminals with a `sudo` prefix:

```bash
sudo kubeadm join 10.0.0.101:6443 --token <your-token> \
    --discovery-token-ca-cert-hash sha256:<your-generated-sha256-hash>

```

### How to Regenerate the Join Token

If your initial setup token expires or gets lost, you can print a brand new join snippet from `manager01` using:

```bash
kubeadm token create --print-join-command

```

---

## 4. Cluster Verification Matrix

Execute these status checks exclusively from `manager01` to confirm the condition of infrastructure objects:

```bash
#
kubectl config view
#
kubectl config current-context
# Check Status and IP Assignments of Compute Infrastructure Nodes
kubectl get nodes -o wide

# Check Status of Core Cluster Daemon Components across Namespaces
kubectl get pods -A

kubectl get pods -n kube-system -o wide

```

```

```