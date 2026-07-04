Here is a clean, comprehensive, and professional `README.md` file that documents the exact architecture and step-by-step setup you just implemented for your CKA gateway infrastructure. You can copy this directly into your documentation repository.

---

```markdown
# CKA Lab Environment: High-Availability Gateway Router Setup

This repository contains the configuration steps to establish a dedicated Ubuntu-based Gateway Router (`CKA-Gateway`) within VMware Workstation. This gateway bridges an external network interface (NAT with Internet access) and an isolated, internal host-only network infrastructure dedicated to the Kubernetes cluster nodes (`manager01`, `node01`, `node02`).

## Network Architecture Overview


```

```
                    [ Physical Host / Internet ]
                                 │
                         (VMware VMnet8 - NAT)
                                 │
                         ┌───────┴───────┐
                         │    ens33      │  (DHCP / 192.168.48.x)
                         │               │
                         │  CKA-Gateway  │
                         │               │
                         │    ens34      │  (Static IP: 10.0.0.199/8)
                         └───────┬───────┘
                                 │
                    (VMware VMnet1 - Host-Only)
                                 │
     ┌───────────────────────────┼───────────────────────────┐
     │                           │                           │

```

┌───────┴───────┐           ┌───────┴───────┐           ┌───────┴───────┐
│   manager01   │           │    node01     │           │    node02     │
│  10.0.0.101   │           │  10.0.0.1     │           │  10.0.0.2     │
└───────────────┘           └───────────────┘           └───────────────┘

```

* **External Interface (`ens33`)**: Configured via DHCP on a VMware NAT Network to provide public internet connectivity to the cluster.
* **Internal Interface (`ens34`)**: Configured with a static IP (`10.0.0.199/8`) acting as the Default Gateway for all Kubernetes cluster components.

---

## Deployment Steps

### Step 1: Netplan Network Configuration (Gateway)
Apply the network interface configuration layout to `/etc/netplan/00-installer-config.yaml` on the **CKA-Gateway** VM:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: true
      dhcp6: true
      optional: true
    ens34:
      accept-ra: true
      addresses:
        - 10.0.0.199/8
      dhcp6: true
      nameservers:
        addresses:
          - 8.8.8.8
        search: []

```

Apply and verify the configuration:

```bash
sudo netplan apply
ip a s

```

### Step 2: Enable Kernel IP Packet Forwarding

Configure the Linux kernel to act as a layer-3 router by passing packets between interfaces. Drop a modular sysctl snippet into configuration directories:

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

```

Load the configuration instantly into the live runtime environment:

```bash
sudo sysctl --system

```

### Step 3: Configure IP Masquerading & Firewall Routing Rules

Configure `iptables` rules to manipulate outbound packet streams. This masks internal IP address fragments behind the gateway's public IP address while tracking connections:

```bash
# Enable IP Masquerading on the external facing interface
sudo iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE

# Forward established and related inbound connections back to the cluster nodes
sudo iptables -A FORWARD -i ens33 -o ens34 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow unrestricted outbound traffic from internal networks out to the internet
sudo iptables -A FORWARD -i ens34 -o ens33 -j ACCEPT

```

### Step 4: Persist Netfilter Rules Across Reboots

Install the persistent Netfilter engine framework to save runtime iptables layers directly to disk:

```bash
sudo apt-get update
sudo apt-get install -y iptables-persistent

```

*(During installation, select **Yes** when prompted to save current IPv4 rules).*

To manually update saved rule configurations in the future, run:

```bash
sudo iptables-save | sudo tee /etc/iptables/rules.v4

```

---

## Downstream Cluster Nodes Verification Matrix

Log into `manager01`, `node01`, or `node02` and complete validation tests to verify structural integrity:

1. **Verify Default Gateway Routing Vector Table**:
```bash
ip route show

```


*Expected Output*: `default via 10.0.0.199 dev ens33 proto static`
2. **Verify Public ICMP Echo Request Pipeline**:
```bash
ping -c 3 8.8.8.8

```


3. **Verify Complete End-to-End DNS Resolution Engine Lookup**:
```bash
sudo apt-get update -y

```



```

```