
---

# AWS WAF & Shield Deployment Guide: Protection Packs on ALB

This document provides a step-by-step production implementation guide to deploy an Application Load Balancer (ALB) protecting Apache backend EC2 instances, covered by an **AWS WAF Protection Pack** configured for automatic DDoS and exploit mitigation.

---

## 🛠️ Architecture Workflow

1. **User Request:** Incoming traffic hits the ALB's DNS name.
2. **Perimeter Inspection:** Before the ALB processes the request, the **AWS WAF Protection Pack** evaluates the traffic against your rule sets.
3. **DDoS/Flood Mitigation:** If a sudden traffic spike or a distributed denial-of-service (DDoS) attack pattern is detected, WAF drops the malicious connections at the perimeter, returning an HTTP `403 Forbidden` response.
4. **Backend Delivery:** Clean traffic safely routes through the Internet Gateway to the target EC2 instances serving the Apache site inside your public/private subnets.

---

## 📋 Step 1: Launch Backend EC2 Instances with User Data

First, deploy your Apache web servers inside your VPC subnets.

1. Open the **Amazon EC2 Console** and click **Launch instance**.
2. **Name:** `Web-Server-Target-01` (Create a second one for high availability if needed).
3. **Application and OS Images (AMI):** Select **Ubuntu** (e.g., Ubuntu Server LTS).
4. **Instance type:** `t2.micro` or `t3.micro` (Free Tier eligible).
5. **Network settings:**
* Ensure it is assigned to your target **VPC**.
* Set **Auto-assign public IP** to **Enable** if deploying directly into a public subnet.
* **Security Group:** Create a security group that allows **HTTP (Port 80)** and **HTTPS (Port 443)** from your load balancer (or anywhere `0.0.0.0/0` temporarily for testing).


6. **Advanced Details (User Data):** Scroll to the very bottom, expand *Advanced Details*, and paste your script exactly into the **User Data** box:

```bash
#!/bin/bash
# Update package lists and automatically accept prompts
yes | sudo apt update

# Install Apache2 web server automatically
yes | sudo apt install apache2 -y

# Create custom index.html file featuring dynamic Hostname and IP Address variables
echo "<h1>Server Details</h1><p><strong>Hostname:</strong> $(hostname)</p><p><strong>IP Address:</strong> $(hostname -I | cut -d' ' -f1)</p>" > /var/www/html/index.html

# Restart Apache to apply any configurations
sudo systemctl restart apache2

```

7. Click **Launch instance**.

---

## 🎯 Step 2: Configure Target Group & Application Load Balancer

Your ALB requires a registered Target Group to route users to your newly created Apache servers.

### 1. Create the Target Group

1. In the left navigation of the EC2 console, scroll down to **Load Balancing** and select **Target Groups**.
2. Click **Create target group**.
3. **Target type:** Select **Instances**.
4. **Target group name:** `Apache-Target-Group`.
5. **Protocol/Port:** `HTTP` on Port `80`.
6. Click **Next**.
7. **Register targets:** Select your launched EC2 instance(s), click **Include as pending below**, and click **Create target group**.

### 2. Create the Application Load Balancer (ALB)

1. In the left navigation, select **Load Balancers** > **Create load balancer**.
2. Select **Application Load Balancer** and click **Create**.
3. **Load balancer name:** `Application-Web-ALB`.
4. **Scheme:** **Internet-facing**.
5. **Network mapping:** Select your VPC and check at least two Availability Zones (Subnets) to ensure high availability.
6. **Security groups:** Select a security group that permits **HTTP (Port 80)** traffic from the internet (`0.0.0.0/0`).
7. **Listeners and routing:** For the HTTP:80 listener, change the Default Action to **Forward to** and select your `Apache-Target-Group`.
8. Click **Create load balancer**. Wait a few minutes for the status to turn from *Provisioning* to *Active*.

---

## 🛡️ Step 3: Deploy AWS WAF Protection Pack & DDoS Mitigations

Now, we will use the updated AWS interface to build out your defense perimeter against DDoS and exploit floods.

1. Open the **AWS WAF & Shield Console**.
2. On the left navigation panel, click **Protection packs (web ACLs)**.
3. Click **Create protection pack (web ACL)**.
4. **Describe Protection Pack:**
* **Name:** `ALB-DDoS-Protection-Pack`
* **Region scope:** Select **Regional resources**.
* **Region:** Ensure this matches the exact AWS region where your ALB is running (e.g., *US East (N. Virginia)* or *Asia Pacific (Mumbai)*).


5. **Associated AWS resources:** Click **Add AWS resources**, choose **Application Load Balancer**, check your `Application-Web-ALB`, and click **Add**. Click **Next**.

---

### Step 4: Add Rate-Limiting & Core Anti-DDoS Rules

To stop a DDoS or HTTP flood, we must implement a **Rate-based rule** alongside AWS Core Managed rules.

1. On the **Rules** step, click **Add rules** > **Add my own rules and rule groups**.
2. Configure a **Rate-based rule** (This defends your application against HTTP flood attacks/DDoS):
* **Rule type:** Rate-based rule
* **Name:** `DDoS-Rate-Limit-Rule`
* **Rate limit:** Set this between `100` and `2000` depending on your expected traffic thresholds (e.g., `300` requests per 5 minutes per single IP address is a safe production baseline).
* **Action:** **Block**.
* Click **Add rule**.


3. Next, add standard managed structural protections. Click **Add rules** > **Add managed rule groups**.
4. Expand **AWS managed rule groups** and enable:
* **Amazon IP reputation list:** Blocks requests from known bad bots, scanners, and malicious DDoS reflection sources.
* **Core rule set (CRS):** Mitigates basic OWASP vulnerabilities that attackers exploit during multi-vector attacks.


5. Set the **Default web ACL action** to **Allow**.
6. Click **Next** through Rule Priority and Metrics, then click **Create protection pack**.

---

## 🧪 Step 5: Test and Verify the Integration

### 1. Test Normal Request via ALB

Copy your Application Load Balancer's **DNS Name** from the EC2 console and paste it into your browser or a terminal window:

```bash
curl http://application-web-alb-123456789.us-east-1.elb.amazonaws.com

```

* **Expected Output:**
```html
<h1>Server Details</h1>
<p><strong>Hostname:</strong> ip-172-31-xx-xx</p>
<p><strong>IP Address:</strong> 172.31.xx.xx</p>

```


*(This validates that your User Data script successfully deployed Apache and your ALB is cleanly routing traffic to the target instance).*

### 2. Verify WAF Protection Under Attack Conditions

If a sudden high-velocity DDoS tool or rapid-fire request machine hits your application from a single source, the rate-limiting rule inside your Protection Pack will instantly kick in.

Once a single IP addresses exceeds your configured request window limit (e.g., 300 requests over 5 minutes), any subsequent requests will be caught and neutralized:

* **Simulated Flood Output:**
```http
HTTP/1.1 403 Forbidden
Content-Type: text/html; charset=utf-8
Content-Length: 263

```



You can view these blocked requests in real time under the **Dashboard** and **AI traffic analysis** tabs directly inside your new WAF Protection Pack console workspace.