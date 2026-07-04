Here is your fully optimized, production-ready automation script. It fixes all the permission, directory, and module bugs we discussed.

I have also added inline comments and tracking echoes so that as the script runs, it explains exactly what it is doing in the terminal.

---

### Complete Installation Script (`k8s-setup.sh`)

You can save this script on **manager01**, **node01**, and **node02**.

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# ==============================================================================
# 1. DEFINE VERSIONS
# ==============================================================================
# Defining explicit version tags ensures variables aren't empty when generating paths.
# Note: Ensure these versions are officially supported by the package repositories.
KUBERNETES_VERSION="v1.34"
CRIO_VERSION="v1.34"

echo "================================================================"
echo "🚀 Starting Kubernetes $KUBERNETES_VERSION & CRI-O Setup Script"
echo "================================================================"

# ==============================================================================
# 2. SYSTEM PREREQUISITES
# ==============================================================================
echo "⚙️  1. Disabling Swap memory (Required by Kubelet)..."
sudo swapoff -a
sudo sed -e '/swap/s/^/#/g' -i /etc/fstab

echo "🌐  2. Loading Linux Kernel modules for cluster networking (overlay & br_netfilter)..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "🛡️  3. Applying bridging sysctl parameters for IP Forwarding & Netfilter..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Load configurations cleanly into live runtime kernel without rebooting
sudo sysctl --system

# ==============================================================================
# 3. REPOSITORY SETUP
# ==============================================================================
echo "📦  4. Updating base apt index and installing system utilities..."
sudo apt-get update
sudo apt-get install -y software-properties-common curl gnupg

echo "📁  5. Creating secure keyrings directory configuration..."
# This ensures gpg won't crash due to a missing parent path folder.
sudo mkdir -p -m 755 /etc/apt/keyrings

echo "🔑  6. Fetching and dearmoring Kubernetes GPG signing key..."
# Fixed: Added 'sudo' to the gpg command to prevent pipe write permission drops.
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | \
    sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "📝  7. Appending Kubernetes official apt entry source list..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "🔑  8. Fetching and dearmoring CRI-O Container Engine GPG signing key..."
curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key | \
    sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "📝  9. Appending CRI-O Engine official apt entry source list..."
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" | \
    sudo tee /etc/apt/sources.list.d/cri-o.list

# ==============================================================================
# 4. PACKAGE INSTALLATION & SERVICE MANAGEMENT
# ==============================================================================
echo "🔄 10. Synchronizing package index matrices from newly added endpoints..."
sudo apt-get update

echo "💾 11. Installing CRI-O runtime alongside Kubernetes core cluster binaries..."
sudo apt-get install -y cri-o kubelet kubeadm kubectl cri-tools

echo "🔒 12. Pinning versions via apt-mark hold to prevent automated package upgrades..."
sudo apt-mark hold kubelet kubeadm kubectl

echo "🚀 13. Reloading systemd controller configurations & activating CRI-O runtime engine..."
# Fixed: We reload daemons and initialize CRI-O *before* Kubelet to prevent crashloops.
sudo systemctl daemon-reload
sudo systemctl enable crio --now

echo "♻️  14. Activating Kubelet agent service engine layer..."
sudo systemctl enable kubelet --now

echo "================================================================="
echo "✅ Script Execution Complete! Node infrastructure is ready."
echo "================================================================="

```

---

### How to Run the Script

1. **Create the file:**
```bash
nano k8s-setup.sh

```


2. Paste the code block above into the editor, save, and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).
3. **Grant execution permissions:**
```bash
chmod +x k8s-setup.sh

```


4. **Execute the script:**
```bash
./k8s-setup.sh

```



### What Happens Next?

* **On `manager01`:** Run your initialization line:
```bash
sudo kubeadm config images pull
sudo kubeadm init --apiserver-advertise-address 10.0.0.101 --pod-network-cidr 172.17.0.0/16

```


*(Note: Since you commented that you plan to install Calico, Calico's default pool config maps perfectly to this `172.17.0.0/16` CIDR or its fallback `192.168.0.0/16`).*
* **On Nodes (`node01`/`node02`):** Simply run your script file, then execute the exact `kubeadm join` string printed by your control plane.