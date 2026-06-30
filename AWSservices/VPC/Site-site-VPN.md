This is a complete, detailed set of steps to successfully execute the Site-to-Site VPN configuration task.

## 🚀 Phase 1: AWS Setup (VPC A & VPC B)

### 1\. Create VPC A (Region A - AWS Side)

  * **1.1. Create VPC A:** Navigate to VPC, click **Create VPC**. Name it `"VPC-A"`, set CIDR **$10.1.0.0/16$**.
  * **1.2. Create Subnets:** Create a public subnet `"VPC-A-public-1"` ($10.1.1.0/24$) and a private subnet `"VPC-A-private-1"` ($10.1.2.0/24$).
  * **1.3. Create & Attach IGW:** Create an Internet Gateway (IGW) named `"VPC-A-igw"` and **attach it to VPC-A**.
  * **1.4. Update Route Table:** Select the main Route Table for VPC-A, **Edit routes**, add a route: Destination **$0.0.0.0/0$** to Target **VPC-A-igw**. **Associate** the public subnet to this Route Table.

### 2\. Create VPC B (Region B - Simulated On-Prem)

  * **2.1. Change Region:** Switch the AWS Console to **Region B** (e.g., Asia Pacific (Mumbai)).
  * **2.2. Create VPC B:** Create a VPC named `"VPC-B"`, set CIDR **$10.2.0.0/16$**.
  * **2.3. Create Subnets:** Create a public subnet `"VPC-B-public-1"` ($10.2.1.0/24$).
  * **2.4. Create & Attach IGW:** Create an IGW named `"VPC-B-igw"` and **attach it to VPC-B**.
  * **2.5. Update Route Table:** Create or edit a public Route Table for VPC-B, add a route: Destination **$0.0.0.0/0$** to Target **VPC-B-igw**. **Associate** the public subnet to this Route Table.

### 3\. Launch EC2 Customer Gateway Host (Region B)

  * **3.1. Launch Instance:** Go to **EC2** $\rightarrow$ **Instances** $\rightarrow$ **Launch instances**.
  * **3.2. Configure:** Name: `"cgw-openswan-mumbai"`. Choose **Amazon Linux 2 AMI**. Instance type: **t3.micro/t2.micro**.
  * **3.3. Network:** Select **VPC-B** and **VPC-B-public-1**. Ensure **Auto-assign Public IP: Enable**.
  * **3.4. Key Pair:** Select or **create a new key pair** and download the `.pem` file.
  * **3.5. Security Group:** Allow **SSH (TCP 22)** from your workstation's public IP. **Launch instance.**
  * **3.6. Note IP:** Once running, **copy the Public IPv4 address**. (This is your Customer Gateway IP).

-----

## 🔒 Phase 2: VPN Provisioning (Region A)

### 4\. Create Virtual Private Gateway (VGW)

  * **4.1. Switch Region:** Switch the AWS Console back to **Region A**.
  * **4.2. Create VGW:** Go to **VPC** $\rightarrow$ **Virtual Private Gateways** $\rightarrow$ **Create virtual private gateway**. Name: `"VPC-A-VGW"`. Create.
  * **4.3. Attach VGW:** Select VGW $\rightarrow$ **Actions** $\rightarrow$ **Attach to VPC** $\rightarrow$ select **VPC-A**. Wait for attachment.

### 5\. Create Customer Gateway (CGW)

  * **5.1. Create CGW:** Go to **VPC** $\rightarrow$ **Customer Gateways** $\rightarrow$ **Create customer gateway**.
  * **5.2. Configure:** Name: `"VPC-B-cgw"`. Routing: **Static**. Device IP Address: **Paste the Public IPv4 address of the EC2** from step 3.6. Create.

### 6\. Create Site-to-Site VPN Connection

  * **6.1. Create VPN:** Go to **VPC** $\rightarrow$ **Site-to-Site VPN Connections** $\rightarrow$ **Create VPN connection**.
  * **6.2. Configure:** Name: `"VPC-A-to-VPC-B-VPN"`. Target gateway type: **Virtual private gateway** $\rightarrow$ select **VPC-A-VGW**. Customer gateway: **VPC-B-cgw**. Routing options: **Static**.
  * **6.3. Static IP prefixes:** Add the remote network: **$10.2.0.0/16$**. Create VPN connection.
  * **6.4. Download Config:** Select the new VPN $\rightarrow$ **Download Configuration**. Vendor: **Generic**. Save the file.
  * **6.5. Wait:** The status will be **Pending**. This may take 5–15 minutes.

### 7\. Enable Route Propagation (VPC A Route Table)

  * **7.1. Propagate:** Go to **VPC** $\rightarrow$ **Route Tables** $\rightarrow$ select the **private** route table for VPC-A $\rightarrow$ **Route propagation** tab $\rightarrow$ **Edit route propagation** $\rightarrow$ **Enable** propagation for **VPC-A-VGW**. Save. (This tells VPC A how to reach $10.2.0.0/16$ through the VGW).

-----

## ⚙️ Phase 3: Customer Gateway Configuration (Region B EC2)

### 8\. Prepare EC2 (Install IPsec and Forwarding)

  * **8.1. SSH:** SSH into the EC2 instance using your `.pem` key:
    ```bash
    ssh -i /path/to/your-key.pem ec2-user@EC2_PUBLIC_IP
    sudo -i
    ```
  * **8.2. Install IPsec:** Install one of the VPN packages:
    ```bash
    yum update -y
    yum install -y libreswan || yum install -y openswan || yum install -y strongswan
    ```
  * **8.3. Enable IP Forwarding:**
    ```bash
    sysctl -w net.ipv4.ip_forward=1
    echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
    sysctl -p
    ```

### 9\. Extract Parameters

  * **9.1. Open Config File:** On your local machine, open the AWS downloaded configuration file.
  * **9.2. Locate Values:** Find the following for **Tunnel 1**:
      * **AWS Peer IP** (The VGW's Public IP)
      * **Pre-Shared Key (PSK)** (The long string of random characters)
      * Note: The task only requires configuring **Tunnel 1**, though AWS provides two for redundancy.

### 10\. Configure IPsec Files

  * **10.1. Navigate:**
    ```bash
    cd /etc/ipsec.d
    ```
  * **10.2. Create Secrets File:** (Replace `REPLACE_WITH_PSK_STRING` with the actual PSK, keeping the double quotes.)
    ```bash
    bash -c "cat > aws-vpn.secrets <<'EOF'
    %any %any : PSK \"REPLACE_WITH_PSK_STRING\"
    EOF"
    chmod 600 aws-vpn.secrets
    ```
  * **10.3. Create Config File:** (Replace `REPLACE_WITH_AWS_PEER_IP` with the AWS Peer IP from the config file.)
    ```bash
    bash -c "cat > aws-vpn.conf <<'EOF'
    conn aws-to-aws
        authby=secret
        auto=start
        left=%defaultroute
        leftid=@cgw
        leftsubnet=10.2.0.0/16    # Local network (VPC-B)
        right=REPLACE_WITH_AWS_PEER_IP
        rightid=@vgw
        rightsubnet=10.1.0.0/16   # Remote network (VPC-A)
        ike=aes256-sha1;modp1024
        phase2alg=aes256-sha1
        keyexchange=ike
        type=tunnel
    EOF"
    ```

### 11\. Start and Verify IPsec

  * **11.1. Restart Service:**
    ```bash
    systemctl restart ipsec || service ipsec restart
    ```
  * **11.2. Check Status:** Wait a moment, then check the status. You are looking for the connection to show as **UP/ESTABLISHED**.
    ```bash
    ipsec status
    ```

-----

## ✅ Phase 4: Verification and Cleanup

### 12\. Verification

  * **12.1. AWS Status:** In the AWS Console (Region A), check the **Site-to-Site VPN Connections** details. **Wait** until at least one of the tunnels shows **Status: UP/Available**.
  * **12.2. Security Group Check (Troubleshooting):** Ensure the **EC2 Security Group** (Region B) allows inbound **UDP 500** and **UDP 4500** from the VGW's public IPs (found in the downloaded config) for IPsec negotiation.
  * **12.3. Test Ping:** To fully test, you need an EC2 in the **VPC A private subnet**. From the **CGW EC2 in VPC B**, attempt to ping the private IP of the VPC A instance (e.g., `ping 10.1.2.10`).

### 13\. Clean up

  * **13.1. Terminate EC2:** Terminate the `"cgw-openswan-mumbai"` EC2 instance in Region B.
  * **13.2. Delete VPN Resources (Region A):** Delete the VPN connection, Customer Gateway, and then detach and delete the VGW.
  * **13.3. Delete VPCs:** Delete VPC A and VPC B (which will also delete associated subnets, route tables, and IGWs).

Do you want to know the specific commands for opening the UDP 500/4500 ports on the EC2 security group?
