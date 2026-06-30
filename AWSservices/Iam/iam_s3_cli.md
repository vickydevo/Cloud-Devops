
# AWS IAM and S3 Guide

## AWS Identity and Access Management (IAM)

AWS IAM (Identity and Access Management) is a service that helps you securely control access to AWS resources. Authentication and authorization are key concepts that determine who can access AWS resources and what actions they can perform.

### 1. Authentication vs. Authorization

#### Authentication:
Authentication verifies the identity of a user or system before granting access. It answers the question, **"Who are you?"**

AWS provides different methods for authentication:
- **IAM Users**: Login credentials (username and password) for the AWS Management Console.
- **Access Keys**: Used for programmatic access (CLI, SDKs).
- **Multi-Factor Authentication (MFA)**: Adds extra security.

#### Authorization:
Authorization determines what actions an authenticated user or system can perform. It answers the question, **"What are you allowed to do?"**
- After authentication, IAM policies are checked to determine what resources a user can access and what actions they are permitted to perform.

### 2. IAM Users
- IAM Users are entities created for individuals or applications interacting with AWS.
- Each IAM user has a unique name within an AWS account and can be assigned:
  - **Programmatic access** (via access keys for CLI or SDKs).
  - **Console access** (via passwords for the AWS Management Console).
- Permissions are granted by attaching policies that define allowed actions.

### 3. IAM Groups
- IAM Groups are collections of IAM users that share similar permissions.
- Instead of attaching policies to individual users, policies are assigned to groups.
- Example: Create groups for **Administrators, Developers, Auditors**, each with appropriate permissions.

### 4. IAM Policies
IAM Policies are JSON documents that define permissions for users, groups, and roles.


**Policy Elements:**
- **Effect**: `Allow` or `Deny`.
- **Action**: Specifies allowed actions (e.g., `s3:ListBucket`).
- **Resource**: Specifies the AWS resources affected (uses ARN: Amazon Resource Name).
- **Principal**: Specifies the user, account, service, or other entity that is allowed or denied access to a resource.
- **Condition (optional)**: Adds conditions, such as IP-based restrictions.

> **Note:** These elements are used in IAM policy JSON documents to define permissions.

---

#### Types of Policies:
- **Managed Policies**:
  - **AWS Managed Policies**: Predefined by AWS (e.g., `AdministratorAccess`, `AmazonS3FullAccess`).
  - **Customer Managed Policies**: Custom policies created by users.
- **Inline Policies**: Directly embedded within a user, group, or role.

### 5. IAM Roles
- IAM Roles provide temporary security credentials instead of long-term credentials (passwords, access keys).
- Roles are assumed by users, applications, or AWS services.
- **Common use cases:**
  - **Cross-account access**: Granting permissions to another AWS account.
  - **EC2 Instance Roles**: Allowing EC2 instances to access AWS services securely.

---

## S3 Inline Policy

### AWS CLI Installation
Reference: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### AWS S3 Documentation
Reference: [AWS S3 CLI Documentation](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)

### Check Current User Identity
```sh
aws sts get-caller-identity
```

### List S3 Buckets
```sh
aws s3 ls
```

### Create an S3 Bucket using AWS CLI
```sh
aws s3 mb s3://frontend-march-25
```

### Enabling Object Ownership
Reference: [AWS S3 Ownership Controls](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3api/put-bucket-ownership-controls.html)

Syntax:
```json
Rules=[{ObjectOwnership=string},{ObjectOwnership=string}]
```
Options:
- `BucketOwnerPreferred`
- `ObjectWriter`
- `BucketOwnerEnforced`

Command:
```sh
aws s3api put-bucket-ownership-controls \
    --bucket frontend-nov-27 \
    --ownership-controls 'Rules=[{ObjectOwnership=ObjectWriter}]'
```

### Check Public Permissions of the Bucket
```sh
aws s3api get-public-access-block --bucket frontend-nov-27
```

### Enable Public Access to the Bucket
```sh
aws s3api put-public-access-block \
    --bucket frontend-nov-27 \
    --public-access-block-configuration '{
        "BlockPublicAcls": false,
        "IgnorePublicAcls": false,
        "BlockPublicPolicy": false,
        "RestrictPublicBuckets": false
    }'
```

### Delete Public Access Block
```sh
aws s3api delete-public-access-block --bucket frontendapp2-sep-27

```

# S3 Bucket-Level ACL Commands

This document provides AWS CLI commands to manage **bucket-level ACLs** for your S3 bucket `frontend-march-28`.

---

## 1. Set the Bucket ACL

### **Make Bucket Private (Default)**
```sh
aws s3api put-bucket-acl --bucket frontend-march-28 --acl private
```
✅ **Only the bucket owner has access (recommended for security).**

---

### **Allow Public Read Access**
```sh
aws s3api put-bucket-acl --bucket frontend-march-28 --acl public-read
```
⚠️ **Warning:** This allows **anyone** on the internet to read objects inside the bucket.

---

### **Allow Public Read & Write (Not Recommended)**
```sh
aws s3api put-bucket-acl --bucket frontend-march-28 --acl public-read-write
```
🚨 **Dangerous:** This allows **anyone** to upload, modify, and delete files.

---




## 2. Check Current ACL Settings
To verify the ACL of your bucket:
```sh
aws s3api get-bucket-acl --bucket frontend-march-28
```


### Enable Public Access for Objects
Reference: [Put Object ACL](https://docs.aws.amazon.com/cli/latest/reference/s3api/put-object-acl.html)



```sh
aws s3api put-object-acl \
    --bucket frontendapp2-sep-27 \
    --key <object-key> \
    --acl public-read
```

### Copy Files to an S3 Bucket
#### Copy a Single File
```sh
aws s3 cp file.txt s3://bucket-name>
```

#### Copy Multiple Files
```sh
aws s3 sync . s3://frontend-nov-27 --acl public-read-write
```

```sh
aws s3 cp <your directory path> s3://bucket-name> --recursive
```

```sh
aws s3 sync s3://mybucket ~/Downloads --recursive
```

### Remove an S3 Bucket
```sh
aws s3 rb s3://bucket-name
```

#### If the Bucket is Not Empty
```sh
aws s3 rb s3://bucket-name --force
```

### List Existing S3 Buckets
```sh
aws s3 ls
```

---
This guide provides a structured overview of AWS IAM concepts and S3 bucket management using AWS CLI. For further details, refer to the AWS documentation links provided.




    
