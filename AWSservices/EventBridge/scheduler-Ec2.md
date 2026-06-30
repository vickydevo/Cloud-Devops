
---

# AWS EC2 Automated Cost-Optimization Guide: Scheduled Start/Stop

Using automated scheduling to manage non-production instances is a standard DevOps best practice to cut cloud spend. This modern approach utilizes **Amazon EventBridge Scheduler** paired with **AWS Systems Manager (SSM) Automation**. It is completely serverless, native, zero-code, and falls within the AWS Free Tier.

This guide uses your local time zone (**Asia/Calcutta**), eliminating the need to manually calculate UTC offsets.

---

## Step 1: Create an IAM Service Role for Automation

Systems Manager requires permissions to stop and start your EC2 instances, and EventBridge Scheduler requires permissions to trigger Systems Manager.

1. Open the **IAM Console** and navigate to **Roles** > **Create role**.
2. **Trusted entity type**: Select **AWS Service**.
3. **Service or use case**: Select **Systems Manager** from the dropdown, then select **Systems Manager - Automation** as your specific use case. Click **Next**.
4. **Permissions policies**: Search for and check the managed policy named **`AmazonSSMAutomationRole`**. Click **Next**.
5. **Role name**: Name the role `EC2-Scheduler-SSM-Role`.
6. Review the configurations and click **Create role**.
7. **Crucial Step (Fixing Trust Relationship)**:
* Click on your newly created **`EC2-Scheduler-SSM-Role`**.
* Go to the **Trust relationships** tab and click **Edit trust policy**.
* Replace the JSON configuration with the following block to allow both Systems Manager and EventBridge Scheduler to assume this role:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com",
          "scheduler.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

```


* Click **Update policy**.


8. Copy the role's **ARN** (e.g., `arn:aws:iam::123456789012:role/EC2-Scheduler-SSM-Role`). You will need this in later steps.

---

## Step 2: Set up the "Start" Schedule (Every day at 11:00 AM Local Time)

### 1. Define Schedule Detail

* Open the **Amazon EventBridge Console**.
* In the left-hand navigation pane, expand **Scheduler** and select **Schedules**.
* Click **Create schedule**.
* **Schedule name**: `Start-EC2-Daily-11AM`
* **Schedule group**: `default`
* **Schedule type**: Select **Recurring schedule**.
* **Schedule pattern**: Select **Cron-based schedule**.
* **Time Zone**: Select **(UTC+05:30) Asia/Calcutta**.
* **Cron expression**: Enter the values below for an exact 11:00 AM local time trigger:
* *Minutes*: `00`
* *Hours*: `11`
* *Day of month*: `*`
* *Month*: `*`
* *Day of week*: `?`
* *Year*: `*`


* **Flexible time window**: Select **Off** (ensures your instances start exactly at 11:00 AM without any queue drift).
* Click **Next**.

### 2. Select Target

* Under **Target API**, select **Templated targets** (Do not use *All APIs*).
* Choose **AWS Systems Manager** -> **StartAutomationExecution**.
* In the **Payload** JSON box, paste the following block:

```json
  {
    "DocumentName": "AWS-StartEC2Instance",
    "Parameters": {
      "InstanceId": [
        "i-0e02b3a46f19b1e7f",
        "i-0a1e30276bd37de79"
      ]
    }
  }

```

* Click **Next**.

### 3. Configure Settings & Permissions

* **Schedule state**: Ensure **Enabled** is toggled on.
* Scroll down to **Permissions** > **Execution role**.
* Choose **Use existing role** and select or paste the ARN of the `EC2-Scheduler-SSM-Role` updated in Step 1.
* Click **Next**, review your configurations, and click **Create schedule**.

---

## Step 3: Set up the "Stop" Schedule (Every day at 2:00 AM Local Time)

### 1. Define Schedule Detail

* In the EventBridge Scheduler dashboard, click **Create schedule** again.
* **Schedule name**: `Stop-EC2-Daily-2AM`
* **Schedule type**: Select **Recurring schedule** -> **Cron-based schedule**.
* **Time Zone**: Select **(UTC+05:30) Asia/Calcutta**.
* **Cron expression**: Enter the values below for a 2:00 AM local time trigger:
* *Minutes*: `00`
* *Hours*: `02`
* *Day of month*: `*`
* *Month*: `*`
* *Day of week*: `?`
* *Year*: `*`


* **Flexible time window**: Select **Off**.
* Click **Next**.

### 2. Select Target

* Under **Target API**, select **Templated targets** (Do not use *All APIs*).
* Choose **AWS Systems Manager** -> **StartAutomationExecution**.
> **Note on Naming:** You select `StartAutomationExecution` here because you are instructing the orchestration engine to *start running* your stop document routine.


* In the **Payload** JSON box, paste the corresponding stop document parameters:

```json
  {
    "DocumentName": "AWS-StopEC2Instance",
    "Parameters": {
      "InstanceId": [
        "i-0e02b3a46f19b1e7f",
        "i-0a1e30276bd37de79"
      ]
    }
  }

```

* Click **Next**.

### 3. Configure Settings & Permissions

* Under **Execution role**, choose **Use existing role** and select the `EC2-Scheduler-SSM-Role`.
* Click **Next**, review your inputs, and click **Create schedule**.

---

## Alternative Approach: Tag-Based Management (Systems Manager Quick Setup)

If your environment dynamically scales with more instances later or you prefer a complete dashboard configuration interface without maintaining individual payload documents, you can use **AWS Systems Manager Quick Setup Resource Scheduler**.

1. Open the **AWS Systems Manager Console**.
2. In the left navigation bar, choose **Quick Setup**.
3. Locate **Resource Scheduler** and click **Create**.
4. **Schedule Configuration**:
* **Time Zone**: Select **Asia/Kolkata** (or your preferred local time).
* **Start time**: Set to `11:00`
* **Stop time**: Set to `02:00`


5. **Target Selection**:
* Select **Tag-based targeting**.
* Define your target key/value pair (e.g., Tag Key: `ScheduleGroup`, Tag Value: `DevOps-Core-Environment`).


6. Click **Create** at the bottom of the page. Systems Manager automatically manages the underlying EventBridge architecture and infrastructure policies for you.
7. **Final Step**: Navigate to your EC2 instance dashboard, select your target instances, and add the corresponding tag: `ScheduleGroup` = `DevOps-Core-Environment`.

```

```