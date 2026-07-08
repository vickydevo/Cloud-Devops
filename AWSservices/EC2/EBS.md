# AWS Amazon Elastic Block Store (EBS) Technical Reference Guide

A comprehensive architectural overview, volume breakdown, and exam preparation guide for **Amazon Elastic Block Store (EBS)**.

---

## Table of Contents
1. [Overview](#overview)
2. [Key Features](#key-features)
3. [EBS Volume Types Comparison](#ebs-volume-types-comparison)
4. [Core Use Cases](#core-use-cases)
5. [Volume Management Operations](#volume-management-operations)
6. [Pricing Structure](#pricing-structure)
7. [Best Architectural Practices](#best-architectural-practices)
8. [AWS Certified SysOps/SA Exam Cram Points](#aws-certified-sysopssa-exam-cram-points)

---

## Overview

**Amazon Elastic Block Store (EBS)** is a scalable, high-performance, block-level storage service designed exclusively for use with Amazon EC2 instances. 

* **Block-Level Storage:** Data is stored and managed in fixed-size units called "blocks" (similar to a raw physical hard drive or SSD), rather than a file-system structure (like EFS) or object storage format (like S3).
* **Network-Attached:** EBS volumes are connected to EC2 instances over a dedicated storage network rather than being physically local to the host hardware. They behave exactly like an external drive pluggable into a server.

---

## Key Features

* **Persistence:** Data outlives the instance lifecycle. If an EC2 instance is stopped or terminated, the data on the attached EBS volume remains completely intact (provided the *Delete on Termination* flag is turned off).
* **Elasticity (Elastic Volumes):** You can dynamically modify volume sizes, tweak throughput, or upgrade volume types (e.g., from `gp2` to `gp3`) on the fly without detaching the volume or disrupting live applications.
* **Durability:** EBS volumes are designed for 99.999% availability. AWS automatically replicates the volume's blocks across multiple physical hardware backends within its specific **Availability Zone (AZ)** to eliminate single points of failure.
* **Snapshots:** Supports point-in-time, incremental backups stored securely in **Amazon S3**. Subsequent snapshots only store changed blocks to optimize costs. You can use snapshots to restore volumes, scale sizes, or copy data across regions.
* **Encryption:** Supports seamless encryption at rest using **AWS KMS (Key Management Service)**. Data is encrypted transparently on the fly as it moves between the host EC2 instance and the storage backend.
* **Multi-Attach (io1/io2):** Allows a single Provisioned IOPS volume to be concurrently attached to multiple EC2 instances within the same Availability Zone. Ideal for clustered, high-availability application nodes running clustered file systems.

---

## EBS Volume Types Comparison

AWS separates EBS into Solid State Drive (SSD) types for transactional workloads and Hard Disk Drive (HDD) types for high-throughput streaming workloads.

| Volume Type | API Name | Max IOPS / Vol | Max Throughput / Vol | Primary Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **General Purpose SSD** | `gp3` | 16,000 | 1,000 MiB/s | Default choice. Balanced cost/performance. Allows independent IOPS scaling. |
| **General Purpose SSD** | `gp2` | 16,000 | 250 MiB/s | Older baseline SSD model. Performance scales linearly with provisioned GiB size. |
| **Provisioned IOPS SSD** | `io1` / `io2` | 64,000 | 1,000 MiB/s | Crucial latency-sensitive databases (e.g., SAP HANA, Oracle). Supports **Multi-Attach**. |
| **Provisioned IOPS SSD (Block Express)** | `io2` BX | 256,000 | 4,000 MiB/s | Highest performing SSD. Sub-millisecond latency for massive enterprise workloads. |
| **Throughput Optimized HDD** | `st1` | 500 | 500 MiB/s | Frequently accessed, large sequential workloads (Big Data, MapReduce, Log Analytics). |
| **Cold HDD** | `sc1` | 250 | 250 MiB/s | Lowest cost storage for infrequently accessed data (Infrequent archival storage, backup servers). |

### Important Throughput Definitions
* **IOPS (Input/Output Operations Per Second):** Measures how many individual read/write tasks the drive can handle every second. Critical for transactional databases.
* **Throughput:** The absolute *rate* at which data is written or read from disk, typically tracked in Megabytes per second (MiB/s). Critical for streaming giant data blocks.

---

## Core Use Cases

* **Production Databases:** Hosting performance-critical storage layers (PostgreSQL, MySQL, MongoDB) that demand predictable, low-latency IOPS profiles.
* **Persistent File Systems:** Building application directory trees that must remain safe even if individual EC2 instances are replaced or automated via Auto Scaling.
* **Business Continuity & Recovery:** Leveraging underlying snapshots to orchestrate backups and cross-region disaster recovery deployments.

---

## Volume Management Operations

### Attaching & Detaching
* Volumes and instances **must reside in the exact same Availability Zone (AZ)** to patch into each other.
* Volumes can be cleanly detached and reattached to a completely different instance if required.

### Dynamic Resizing
* You can extend an EBS volume size on the fly. 
* While the storage volume scales immediately at the AWS infra layer, you must manually run the OS-level partition extension utility (like `growpart` and `resize2fs` or `xfs_growfs` in Linux) to make the operating system recognize the new space.
* *Note: Volume sizes can only be increased, never decreased.*

### Monitoring Metrics
All monitoring performance details dump natively into **Amazon CloudWatch**. Key metrics to track include:
* `VolumeReadOps` / `VolumeWriteOps` (To calculate active IOPS usage).
* `VolumeQueueLength` (Tracks processing backlogs; high queues signal that you need higher performance tiers).

---

## Pricing Structure

EBS consumption metrics compile across four parameters:
1. **Provisioned Capacity:** Total gigabytes (GiB) allocated per month (regardless of whether the drive is empty or full).
2. **Provisioned Performance:** Extra fees for explicit IOPS and Throughput thresholds added over baseline minimums (applies to `gp3`, `io1`, `io2`).
3. **Snapshot Storage:** The total size of compressed, incremental data snapshots retained inside Amazon S3.
4. **Data Transfer:** Standard AWS network data out costs when copying snapshots across different geographical regions.

---

## Best Architectural Practices

1. **Automate Snapshots Regularly:** Leverage **AWS Data Lifecycle Manager (DLM)** to automatically schedule, retain, and clean up snapshots.
2. **Enforce Encryption Globally:** Enable the *Encryption by Default* region setting inside the EC2 dashboard to ensure every newly created volume is secured out of the box.
3. **Transition to gp3:** Migrate legacy volume structures from `gp2` to `gp3` to secure up to a 20% cost reduction while unlocking independent performance provisioning.
4. **Decouple App and State:** Keep your app servers stateless. Save application code on the root drive, but place all production databases and media states onto separate, dedicated EBS data volumes.

---

## AWS Certified SysOps/SA Exam Cram Points

* 💡 **The AZ Constraint:** An EBS volume **cannot** natively cross AZ boundaries. To move an EBS volume to another AZ or Region, you must create a snapshot of it, copy the snapshot, and restore it into the new target zone.
* 💡 **Delete on Termination:** By default, the root EBS volume containing the OS is set to **Delete on Termination = True** when launching an EC2 instance. Additional attached data volumes default to **False**. You can override these defaults during creation.
* 💡 **Root Volumes vs HDDs:** You **cannot** use HDD volumes (`st1`, `sc1`) as bootable root volumes. Root volumes must use SSD variants (`gp2`, `gp3`, `io1`, `io2`).
* 💡 **Auto Scaling Volume Mechanics:** When an Auto Scaling Group terminates an instance, any attached non-root EBS volume will be detached. If using stateful configurations, bootstrap scripts must run at boot to cleanly reattach existing EBS volumes via the AWS CLI/API.