

An **Assume Role Policy** (or **Trust Policy**) is a special type of resource-based policy that must be attached to an **IAM Role**. Its sole purpose is to define **which entities** (users, services, or accounts) are allowed to **assume** (or take on) the identity and permissions of that role.

-----

## 🔑 Anatomy of an Assume Role Policy

An Assume Role Policy is a JSON document that uses the `"Principal"` element to specify the trusted entity, and the action **`sts:AssumeRole`** to grant the trust.

### 1\. ⚙️ Basic Structure

The core action granted in a Trust Policy is always `sts:AssumeRole`, which refers to the AWS Security Token Service (STS) API call used to switch to or use the role.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { 
        /* The entity that is ALLOWED to assume this role */ 
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

-----

## 2\. 👥 Common Assume Role Policy Examples

The value of the `"Principal"` element determines *who* can assume the role. Here are the three most common scenarios:

### A. **Same-Account User/Role Access**

To allow a specific **user** or **role** within the **same AWS account** to assume this role.

| Principal Type | Example Value |
| :--- | :--- |
| **IAM User** | `"arn:aws:iam::123456789012:user/DevUser"` |
| **IAM Role** | `"arn:aws:iam::123456789012:role/AutomationRole"` |

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/DevUser"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### B. **Cross-Account Access (Delegation)**

This is the standard pattern for allowing an entire **external AWS account** to assume this role.

| Principal Type | Example Value |
| :--- | :--- |
| **AWS Account** | `"987654321098"` |

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::987654321098:root" 
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "MyAppExternalKey" 
        }
      }
    }
  ]
}
```

> 💡 **Best Practice:** The **`Condition`** using `sts:ExternalId` is highly recommended for cross-account access to prevent a confused deputy problem and ensure only your intended application or user in the external account can assume the role.

### C. **AWS Service Access (Service Roles)**

To allow an AWS service (like EC2, Lambda, or CodePipeline) to assume this role to perform actions on your behalf. This is defined using the service's **Service Principal**.

| Principal Type | Example Value |
| :--- | :--- |
| **Service Principal** | `"ec2.amazonaws.com"`, `"lambda.amazonaws.com"` |

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com" 
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

-----

## 📝 Steps to Create a Role with a Trust Policy

1.  **Define the Trust Policy (This is the policy you write):** Write the JSON document specifying who (the `Principal`) is trusted to assume the role using the `sts:AssumeRole` action.
2.  **Create the IAM Role:** Create a new IAM role and attach the Trust Policy defined in step 1.
3.  **Attach Permissions Policy:** Attach one or more standard **Permissions Policies** (e.g., S3 Read-Only, EC2 Full Access) to the role. These define *what* the role is allowed to do *after* it has been assumed.
4.  **Set up the Assuming Entity (For Cross-Account):** In the trusted account, the user/role must have a separate **Identity Policy** that explicitly allows them to call `sts:AssumeRole` on the target role's ARN.

