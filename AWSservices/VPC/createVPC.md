# AWS VPC Setup Guide

This guide outlines the steps to manually create a custom Virtual Private Cloud (VPC) on AWS with public internet access.

---
### Step 1: Create the VPC
1. Navigate to the **VPC Dashboard** in the AWS Console.
2. Click **Create VPC**.
3. Select **VPC only**.
---
<img width="1448" height="742" alt="Image" src="https://github.com/user-attachments/assets/2687ca4e-2881-4ac6-83dd-7c56687cb90d" />



4. Configure the following:
   * **Name tag:** `My-VPC`
   * **IPv4 CIDR block:** `11.0.0.0/24`
5. Click **Create VPC**.

### Step 2: Create Subnets
1. Go to **Subnets** (left menu) → **Create subnet**.
2. **VPC ID:** Select `My-VPC`.
---
<img width="1256" height="350" alt="Image" src="https://github.com/user-attachments/assets/385b1657-e946-4f87-bf52-e437fe7cae58" />


3. Configure the subnet:
   * **Subnet name:** `My-VPC-Pub-Sub-1`
   * **Availability Zone:** Choose one (e.g., `us-east-1a`)
   * **IPv4 CIDR block:** `11.0.0.0/27`
---
<img width="1357" height="716" alt="Image" src="https://github.com/user-attachments/assets/3986e53e-8699-40fb-9f55-3e3b0082d746" />

4. Click **Create subnet**.

### Step 3: Create & Attach Internet Gateway (IGW)
1. Go to **Internet gateways** (left menu) → **Create internet gateway**.
2. **Name tag:** `My-IGW`.
---
<img width="1660" height="575" alt="Image" src="https://github.com/user-attachments/assets/148dd546-6832-4bb5-9215-96da3ea0157e" />


3. Click **Create internet gateway**.

4. **Action Required:** Once created, click **Actions** → **Attach to VPC**.
5. Select `My-VPC` and click **Attach internet gateway**.
<img width="1883" height="347" alt="Image" src="https://github.com/user-attachments/assets/da05d972-004b-4b29-9df9-5e6ecc205eb7" />

### Step 4: Configure Route Tables
1. Go to **Route tables** (left menu) → **Create route table**.
2. **Name:** `MY-PUB-ROUTE`.
3. **VPC:** Select `My-VPC`.
---
<img width="1866" height="661" alt="Image" src="https://github.com/user-attachments/assets/81bb1da8-0c32-48ed-b54f-8bfa2bbb8fd0" />

4. Click **Create route table**.

#### A. Edit Routes (Enable Internet Access)
1. Select `Public-Route-Table` from the list.
2. Click the **Routes** tab → **Edit routes**.
---
<img width="1868" height="582" alt="Image" src="https://github.com/user-attachments/assets/15bdb31b-a525-444f-b5c8-a7f4927cb785" />

3. Click **Add route** and enter:
   * **Destination:** `0.0.0.0/0`
   * **Target:** Select **Internet Gateway** → `My-IGW`
   ---
   <img width="1862" height="491" alt="Image" src="https://github.com/user-attachments/assets/6c6ad00c-3f23-4de9-a1a1-d32fd5c30e0f" />

4. Click **Save changes**.


#### B. Subnet Association (Link Subnet to Route Map)
1. With `MY-PUB-ROUTE` selected, click the **Subnet associations** tab.
2. Click **Edit subnet associations**.
---
<img width="1872" height="767" alt="Image" src="https://github.com/user-attachments/assets/dacdaa5b-9bc9-4c3d-ad4d-732a8927d50f" />

3. Check the box for `My-VPC-Pub-Sub-1`.
---
<img width="1865" height="542" alt="Image" src="https://github.com/user-attachments/assets/c5b2d3dc-95bf-4115-a53b-9865f1ac98d5" />

4. Click **Save associations**.

---

## ✅ Verification
Your VPC is now set up. Any resource launched into `Public-Subnet-1` with a public IP address will be able to reach the internet via the Internet Gateway.

## 📋 Configuration Summary

| Component | Value | Description |
| :--- | :--- | :--- |
| **VPC CIDR** | `11.0.0.0/24` | Provides ~256 IP addresses. |
| **Subnet CIDR** | `11.0.0.0/27` | Provides 32 IP addresses (251 usable). |
| **Route Target** | `0.0.0.0/0` | Represents all internet traffic. |

