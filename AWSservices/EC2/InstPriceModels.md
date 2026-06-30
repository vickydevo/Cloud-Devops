# AWS Compute Purchasing & Capacity Management Architecture

This repository contains documentation outlining the mechanics, trade-offs, and combinations of AWS instance pricing models and capacity reservation strategies.

Understanding the decoupling of **financial discounts** from **physical capacity guarantees** is critical for building cost-effective, resilient cloud infrastructure.

---

## 🧭 Core Architectural Concepts

When provisioned on AWS, an EC2 instance operates under two distinct frameworks:

1. **Billing Framework:** How much you pay for the compute time (e.g., On-Demand, Spot, Savings Plans, RIs).
2. **Capacity Framework:** Whether hardware is physically allocated and guaranteed to be available when a launch request is made.

---

## 🏛️ The Three Mechanisms for Guaranteed Capacity

To completely eliminate `InsufficientInstanceCapacity` errors, you must use one of the following configurations. These options ensure that physical hardware is reserved for your exclusive use within a designated **Availability Zone (AZ)** inside the AWS data center.

### 1. Dedicated Hosts

Rents an entire physical blade server in an AWS rack exclusively for your AWS account.

* **Guaranteed Capacity:** 100%
* **Hardware Isolation:** Full physical isolation from other tenants.
* **Primary Use Case:** Bring Your Own License (BYOL) compliance (e.g., matching physical cores/sockets for Windows/SQL Server) or strict regulatory multi-tenancy restrictions.
* **Billing:** Billed for the host per hour, regardless of how many instances are active on it.

### 2. On-Demand Capacity Reservations (ODCR)

A pure hardware booking mechanism that separates capacity assurance from any pricing model.

* **Guaranteed Capacity:** 100%
* **Hardware Isolation:** None (instances deploy on standard, shared multi-tenant hardware).
* **Primary Use Case:** Short-term capacity locks for critical events (e.g., big data migrations, disaster recovery drills, major traffic spikes).
* **Billing:** Charged at standard On-Demand rates for the specified capacity, *even if left completely empty*. Can be canceled at any time.

### 3. Reserved Instances (Zonal Scope)

Combines a long-term financial commitment with a hardware reservation.

* **Guaranteed Capacity:** 100%
* **Configuration Requirement:** You must explicitly scope the RI to a **specific Availability Zone** (e.g., `us-east-1a`).
* **Trade-Off:** You lose "Size Flexibility" across the instance family, but you gain absolute capacity assurance alongside the discount.

---

## 💸 Financial Discounts vs. Capacity Guarantees

Many teams mistakenly assume that making a financial commitment automatically guarantees hardware availability. The matrix below defines which models provide cost savings versus capacity assurance.

| Strategy / Tool | Provides Financial Discount? | Provides Capacity Guarantee? | Scope Needed for Guarantee |
| --- | --- | --- | --- |
| **Spot Requests** | ✅ Yes (Up to 90% off) | ❌ No | None (Subject to termination) |
| **Savings Plans** | ✅ Yes (Up to 72% off) | ❌ No | None (Strictly a billing construct) |
| **Regional RIs** | ✅ Yes (Up to 72% off) | ❌ No | None (Applies broad region-wide discount) |
| **Zonal RIs** | ✅ Yes (Up to 72% off) | ✅ Yes | Must be scoped to a **Specific AZ** |
| **Capacity Reservations** | ❌ No (Standard On-Demand) | ✅ Yes | Must be target-scoped to an **AZ** |
| **Dedicated Hosts** | ⚠️ Varies | ✅ Yes | Physical allocation in selected **AZ** |

---

## 📊 The Normalization Sizing Grid

For **Regional RIs** and **Savings Plans**, AWS evaluates usage using **Normalized Units per Hour** rather than physical machine counts. This allows a single purchase to cover varying instance sizes within the same family automatically.

The standard normalization multipliers are mapped below:

| Instance Size | Normalization Factor (Units/Hr) |
| --- | --- |
| **nano** | 0.25 |
| **micro** | 0.50 |
| **small** | 1.00 |
| **medium** | 2.00 |
| **large** | 4.00 |
| **xlarge** | 8.00 |
| **2xlarge** | 16.00 |

### 🧮 Capacity Calculation Formula

$$\text{Total Instances Covered} = \frac{\text{Purchased Normalized Units}}{\text{Target Size Normalization Factor}}$$

* **Example:** Purchasing **100 Normalized Units** yields the capacity to run:
* $\frac{100}{0.50} =$ **200 `.micro` instances**
* $\frac{100}{1.00} =$ **100 `.small` instances**
* $\frac{100}{4.00} =$ **25 `.large` instances**



---

## 🛠️ Production Design Blueprint: The Modern Hybrid Approach

To achieve the optimal balance of **maximum structural flexibility**, **deepest financial discounts**, and **100% guaranteed availability**, enterprise production architectures deploy a hybrid configuration:

1. **Provision Compute Savings Plans:** Establishes the organization-wide baseline spend commitment to secure up to 72% discounts across families, regions, and serverless compute (Fargate/Lambda).
2. **Deploy Target Capacity Reservations (ODCR):** Layered directly on top of mission-critical production Availability Zones.

> **Result:** AWS automatically maps the financial discounts of the Savings Plan onto the physical hardware held by the Capacity Reservation. This eliminates capacity constraints while maintaining absolute cost efficiency.