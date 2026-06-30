

# 🛠️ S3 Bucket Creation Guide 


## 1. General Configuration (Basic Setup)

The first steps establish the bucket's location and purpose.

1.  **Sign In** to the AWS Management Console and navigate to the **S3** service.
2.  Click the **"Create bucket"** button.
3.  **AWS Region:** Select the Region geographically closest to your users or other AWS resources (e.g., `Asia Pacific (Mumbai) ap-south-1`).
4.  **Bucket Name:** Enter a globally unique name. (e.g., `my-insights-project-2025-latest`)
    * *Note:* The name must be 3 to 63 characters and contain only lowercase letters, numbers, periods, and hyphens.

### Bucket Type
5.  **Bucket Type:** Select `General purpose`.
    * **Rationale:** This is the recommended default, providing **redundancy across multiple Availability Zones**. (The `Directory` type is specialized for low-latency use cases using S3 Express One Zone).

<img width="1796" height="666" alt="Image" src="https://github.com/user-attachments/assets/52ef8040-93f3-4145-9edc-32d4cb8e6a84" />

---

## 2. Access Control & Object Ownership (Security Defaults)

Security is paramount; always start with the most restrictive settings.

### Object Ownership
6.  **Object Ownership:** Select **`ACLs disabled (recommended)`**.
    * **Rationale:** Simplifies access control by ensuring all access permissions are managed **centrally** using **IAM policies** and **Bucket Policies**, not ACLs.

### Block Public Access
7.  **Block Public Access settings for this bucket:** Ensure **`Block all public access`** is checked (this is the AWS default).
    * **Rationale:** This is a crucial security layer that overrides all other settings to **prevent accidental public exposure**. AWS recommends leaving this enabled unless you have a specific public-facing use case (like static website hosting).

<img width="1756" height="645" alt="Image" src="https://github.com/user-attachments/assets/bd855903-3580-45af-85ab-b359759dd9fe" />
---

## 3. Advanced Management

### Bucket Versioning
8.  **Bucket Versioning:** Select **`Enable`**.
    * **Rationale:** Versioning is key for **data resilience** as it preserves every object version, allowing easy recovery from accidental deletions or overwrites.

### Tags
9.  **Tags (optional):** Add tags (e.g., `Project: Insights`, `Environment: Dev`).
    * **Rationale:** Essential for **cost allocation** and grouping resources for IAM permissions.
<img width="1602" height="547" alt="Image" src="https://github.com/user-attachments/assets/4f3bfedf-206b-47da-bad2-aa9858faf480" />
---

## 4. Default Encryption (Security at Rest)

Every bucket should have default encryption enabled.

10. **Default encryption:** Select the required **Encryption type**.

| Encryption Type | Rationale (Best Practice) |
| :--- | :--- |
| ✅ **Server-side encryption with Amazon S3 managed keys (SSE-S3)** | **Recommended Default:** Strong, free encryption (AES-256), suitable for most general data. |
| **Server-side encryption with AWS Key Management Service keys (SSE-KMS)** | Use if you need to manage your own key policies and require an **audit trail** of key usage via **CloudTrail**. |

11. **Bucket Key:**
    * If you chose **SSE-KMS**, select **`Enable`** to significantly **reduce KMS API call costs**. (Not supported for DSSE-KMS).

---

## 5. Advanced Settings (Compliance)

12. **Object Lock:** Select **`Disable`** (unless you specifically require WORM/compliance).
    * **Note:** Enabling Object Lock automatically enables Versioning and is used for strict regulatory compliance, preventing objects from being deleted or overwritten.

<img width="1597" height="721" alt="Image" src="https://github.com/user-attachments/assets/6e7cf41a-3753-45c4-b7ce-e9317cf5c7ca" />

## Final Step
13. Click the **"Create bucket"** button.

