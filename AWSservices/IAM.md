# AWS IAM Fundamentals

A concise reference for AWS Identity and Access Management (IAM): how identities are authenticated, authorized, and granted permissions to access AWS resources.

## 1. Authentication vs Authorization

These two concepts form the foundation of IAM:

| Concept | Question | Purpose | IAM features |
|---|---:|---|---|
| Authentication | "Who are you?" | Verifies identity | IAM Users (passwords, access keys, MFA), IAM Roles (temporary credentials) |
| Authorization | "What are you allowed to do?" | Determines access rights | IAM Policies attached to Users, Groups, or Roles |

## 2. IAM Identities: Users, Groups, and Roles

IAM defines the "who" and "how" of access.

### 2.1 IAM Users
- Definition: Entity representing an individual or application using long-term credentials (console password, access keys).
- Permissions: Grant by attaching Policies to the User.
- Best practice: Prefer temporary credentials and MFA; use Roles for privileged tasks.

### 2.2 IAM Groups
- Definition: Collection of IAM Users for centralized permission management.
- Management: Attach Policies to Groups; members inherit permissions.
- Example: Create `App_Devs` group, attach EC2 and S3 policies, add developer users to the group.

### 2.3 IAM Roles
- Definition: Identity without long-term credentials; assumed by trusted entities (EC2, Lambda, users from another account, federated users).
- Trust Policy: Specifies who can assume the role (e.g., `ec2.amazonaws.com`).
- Permissions Policy: Specifies allowed actions after assumption.
- Best practice: Use Roles for services that access other AWS resources.

## 3. IAM Policies and Permissions

A Policy is a JSON document that defines permissions. Each Statement typically contains:
- Effect — "Allow" or "Deny"
- Action — AWS API calls (e.g., `s3:GetObject`)
- Resource — ARN or resource target (e.g., `arn:aws:s3:::my-bucket/*`)
- Principal — (used in Trust or Resource policies) who the identity is

## 4. Managed vs Inline Policies

- Managed Policies
    - AWS Managed: created and maintained by AWS (e.g., `AdministratorAccess`).
    - Customer Managed: created in your account; reusable across identities.
- Inline Policies
    - Embedded directly into a single User/Group/Role.
    - Deleted with the identity; not reusable.
    - Use when a one-to-one policy-to-identity relationship is required.

---

End of document.