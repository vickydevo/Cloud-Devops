 Starting from **Step 1**, containing ONLY the EC2 launch steps for your already-created VPC.

---
# Launch EC2 Instance Inside Existing AWS VPC

This guide explains how to launch an EC2 instance inside the VPC and networking configuration you have already created (`My-VPC`, `My-VPC-Pub-Sub-1`, IGW, and public route table).

---

## Step 1 — Create a Security Group
1. Open **EC2 Dashboard** → **Security Groups**
---
<img width="1896" height="663" alt="Image" src="https://github.com/user-attachments/assets/b389e98d-42cf-4000-8e35-424796cb9b12" />

2. Click **Create security group**
3. Configure:
   - **Security group name:** `My-VPC-SG`
   - **Description:** Allows SSH (and optional HTTP)
   - **VPC:** `My-VPC`
4. Add **Inbound rules**:
   - **SSH** → Port **22** → Source: `0.0.0.0/0`
   - *(Optional)* **HTTP** → Port **80** → Source: `0.0.0.0/0`
---
<img width="1910" height="770" alt="Image" src="https://github.com/user-attachments/assets/74a10f9c-4c65-4573-b292-99169c9c794d" />

5. Click **Create security group**

---

## Step 2 — Launch the EC2 Instance
1. Go to **EC2 Dashboard** → Click **Launch instance**
2. Configure:
   - **Name:** `Linux`
   - **AMI:** Ubuntu Server 24.04 LTS  (or another AMI of your choice)
   - **Instance Type:** `t3.micro` (free-tier eligible)
3. Under **Key pair**, choose an existing key or create a new one
4. Expand **Network settings** and configure:
   - **VPC:** `My-VPC`
   - **Subnet:** `My-VPC-Pub-Sub-1`
   - **Auto-assign Public IP:** **Enable**
   - **Firewall:** Select **Existing security group**
   - Choose **My-VPC-SG**
---
<img width="1452" height="747" alt="Image" src="https://github.com/user-attachments/assets/c0d56b7f-d33c-4280-a51d-bc8074b22de9" />

5. Keep storage defaults  (8gb , gp3)
6. Add User Data (NGINX Setup Script)

Scroll down to **Advanced details** → **User data**, and paste:

```bash
#!/bin/bash

# Wait for cloud-init & dpkg lock issues
sleep 30

sudo apt update --fix-missing -y

# Retry installation until it succeeds
until sudo apt install -y nginx; do
    echo "Retrying nginx installation..."
    sleep 5
done

sudo systemctl enable nginx
sudo systemctl start nginx

echo "<h1>Nginx installed and started successfully on Ubuntu 24.04. <br> Private IP: $(hostname -I | awk '{print $1}')</h1>" > /var/www/html/index.html

```

7. Click **Launch instance**
---

## Step 3 — Verify the EC2 Instance

### Get the Public IP
1. In the **EC2 Dashboard**, select the instance
2. Copy the **Public IPv4 address**

### Connect via SSH
```bash
ssh -i mykey.pem ec2-user@<public-ip>
```

### Test Internet Connectivity

Inside the instance, run:

```bash
ping amazon.com
```
Open your browser and visit:

```bash
http://<EC2-Public-IP>
```
---
4. Expected Output

You should see:
```bash
Nginx installed and started successfully on Ubuntu 24.04.
Private IP: <your-private-ip>
```
---

## ✔️ EC2 Launch Completed

Your EC2 instance is now live inside your custom VPC with full internet access using:

* VPC: `11.0.0.0/24`
* Subnet: `11.0.0.0/27`
* IGW: `My-IGW`
* Route Table: Public route (`0.0.0.0/0 → My-IGW`)

```

