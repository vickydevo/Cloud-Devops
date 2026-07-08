# AWS Spot Instances: Architecture, Lifecycles, and Hands-on Labs

A comprehensive technical guide to understanding AWS Spot Instances, distinguishing between request lifecycles, configuring advanced interruption behaviors like Hibernation, and executing hands-on labs.

---

## Table of Contents
1. [What is a Spot Instance?](#what-is-a-spot-instance)
2. [Spot Request Lifecycles](#1-spot-request-lifecycles)
3. [Interruption Behaviors & Hibernation Deep Dive](#2-interruption-behaviors--hibernation-deep-dive)
4. [Hands-on Labs](#3-hands-on-labs)
    * [Lab 1: Deploying a One-Time Spot Request](#lab-1-deploying-a-one-time-spot-request)
    * [Lab 2: Deploying a Persistent Spot Request with Hibernation](#lab-2-deploying-a-persistent-spot-request-with-hibernation)
    * [Lab 3: Proper Clean-up & Tear Down](#lab-3-proper-clean-up--tear-down)

---

## What is a Spot Instance?

An AWS Spot Instance allows you to check out unused EC2 computing capacity at massive discounts (up to 90% off On-Demand pricing). The core operating constraint is that **AWS can reclaim this capacity at any moment with a mandatory 2-minute warning notification** when On-Demand demand spikes.

---

## 1. Spot Request Lifecycles

When submitting a Spot request, you must define how the request profile behaves after an interruption occurs:

| Feature | One-Time Request | Persistent Request |
| :--- | :--- | :--- |
| **Behavior on Interruption** | The instance is terminated, and the Spot request is **automatically closed**. | The instance is interrupted, but the Spot request **remains active** in a waiting state. |
| **Self-Healing Capability** | **No.** If capacity becomes available again in the pool, nothing happens. | **Yes.** As soon as spare capacity returns to the AWS pool, a replacement instance is automatically provisioned. |
| **Best Used For** | Stateless batch jobs, short data analysis scripts, or quick transient testing blocks. | Distributed stateless web servers, CI/CD runners, or fault-tolerant container clusters. |

---

## 2. Interruption Behaviors & Hibernation Deep Dive

When AWS issues the 2-minute warning, your instance will execute one of three configured behaviors:

1. **Terminate:** The instance is permanently destroyed. For persistent requests, a completely fresh node (with a clean root volume) boots up when capacity allows.
2. **Stop:** The instance is shut down normally. Ephemeral data is lost, but data on attached EBS volumes is preserved.
3. **Hibernate (Stateful Pausing):** The instance freezes running processes, takes everything currently loaded into its short-term **RAM**, and dumps it directly onto the encrypted EBS root volume before powering down.



### Why use Hibernation?
It is ideal for workloads with heavy setup times or long compilation phases (e.g., massive Java applications or machine learning models). When capacity returns, the kernel reads the RAM state back from the EBS disk, allowing your application to resume *exactly where it left off* without losing hours of computational progress.

### Prerequisites for Hibernation
* **Persistent Request Only:** You cannot hibernate a one-time request. You must select **Persistent** in your configuration to unlock the Hibernate option.
* **EBS Encryption:** The root volume **must** be encrypted to securely protect the raw RAM states written to disk.

---

## 3. Hands-on Labs

### Lab 1: Deploying a One-Time Spot Request
1. Open the **EC2 Dashboard** and click **Launch Instances**.
2. Name your instance `spot-onetime-lab`.
3. Scroll to the bottom, expand **Advanced Details**, and check **Request Spot Instances**.
4. Ensure **Request type** is set to **One-time** and **Interruption behavior** is set to **Terminate**.
5. Launch the instance.

### Lab 2: Deploying a Persistent Spot Request with Hibernation
1. Open the **EC2 Dashboard** and click **Launch Instances**.
2. Name your instance `spot-persistent-hibernate-lab`.
3. Under **Configure storage**, expand the advanced volume options and ensure your root volume has **Encryption** enabled.
4. Scroll down, expand **Advanced Details**, and check **Request Spot Instances**.
5. Change **Request type** to **Persistent**. 
6. Open the **Interruption behavior** dropdown and select **Hibernate**. *(Note: This option is greyed out if step 5 is not completed first).*
7. Launch the instance.

### Lab 3: Proper Clean-up & Tear Down

> ⚠️ **CRITICAL ARCHITECTURAL NOTE:** If you try to terminate a persistent instance manually via the standard instances panel, the persistent request rule will treat it as an accidental failure and immediately spin up a new server. You must destroy the request foundation first.

Follow these steps to clean up cleanly:
1. In the left-hand menu of the EC2 Dashboard, navigate to **Spot Requests**.
2. Select your active persistent or hibernated request profile.
3. Click **Actions** -> **Cancel Spot Request**.
4. In the confirmation dialog box, check the optional box that reads: **"Terminate companion instances"**.
5. Click **Confirm**. The rule is permanently removed, and the associated EC2 instances are safely destroyed without spawning replacements.