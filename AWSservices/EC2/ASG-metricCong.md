Based on your exact dashboard layout, you have **0 lifecycle hooks** and **0 warm pools** configured, which is perfect for this test. Your instances are healthy and `InService`.

To make this group scale up when CPU or HTTP traffic spikes, you need to navigate away from the **Details** / **Instance management** tabs and open the **Automatic scaling** tab.

Here is exactly where to click and what to update on your current dashboard to get it working.

---

## 🛠️ Step 1: Navigate to the Metric Configuration

1. Look at the sub-menu tabs on your screen: `Details`, `Integrations`, **`Automatic scaling`**, `Instance management`, etc.
2. Click directly on **`Automatic scaling`**.
3. Scroll down to the section named **Dynamic scaling policies** and click **Add scaling policy**.

---

## 📈 Step 2: Configure the CPU Auto-Scaling Rule

To handle the **CPU increase** from your `stress-ng` script, configure a **Target Tracking Policy** right inside that menu:

* **Policy type:** `Target tracking scaling`
* **Policy name:** `vignan-cpu-tracking`
* **Metric type:** `Average CPU utilization`
* **Target value:** `50` *(Since your script hits 85%, this guarantees it fires).*
* **Instance warmup:** Change this from 300 to **60** seconds.

Click **Create**. AWS will now automatically monitor the average CPU of `i-0cbbaee4c6b3176df` and `i-0e8c6ecdfc04e15e2` together.

---

## 🌐 Step 3: Configure the HTTP Request Traffic Rule

To make the group scale when your ApacheBench (`ab`) **concurrent request traffic script** runs, you cannot use basic EC2 metrics because an EC2 instance doesn't inherently know how many HTTP requests are hitting it.

You must attach an **Application Load Balancer (ALB)** to your ASG first.

### Part A: Attach your Load Balancer (If not already done)

1. Go back to the **Details** tab on your current screen.
2. Find the **Load balancing** section and click **Edit**.
3. Check the box for **Application Load Balancer or Network Load Balancer** and select your target ALB group. Click **Save**.

### Part B: Add the Traffic Policy

1. Go back to **Automatic scaling** ➡️ **Add scaling policy**.
2. **Policy type:** `Target tracking scaling`
3. **Metric type:** Select **`ALBRequestCountPerTarget`** (Application Load Balancer request count per target).
4. **Target group:** Select the target group attached to your Nginx ALB.
5. **Target value:** Set this to a low test value like `1000` (requests per instance).

---

## ⚡ How to Run Your Double-Test Now

Once those two policies are visible under your **Automatic scaling** tab, you are ready to test:

1. **For CPU scaling:** SSH into **both** `i-0cbbaee4c6b3176df` and `i-0e8c6ecdfc04e15e2` at the same time and run your `./burn-cpu.sh` script.
2. **For Traffic scaling:** Run your `./flood-traffic.sh` script targeting the DNS name of your Application Load Balancer.

Both methods will now successfully push your group past its capacity limits and force your ASG to scale out to 3 or 4 instances!