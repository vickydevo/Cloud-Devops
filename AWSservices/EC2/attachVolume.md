When you want to **attach a brand-new EBS volume** to an existing EC2 instance, AWS treats it exactly like plugging an external USB hard drive into a computer.

Here is the complete real-time implementation guide to attaching the volume in the AWS Console, mounting it inside Ubuntu, and creating a fresh filesystem.

---

## 🛠️ Phase 1: Attach the Volume in the AWS Console

Before your operating system can see the storage, you must physically map it to the virtual machine.

1. Open the **AWS EC2 Console** and navigate to **Elastic Block Store** ➡️ **Volumes**.
2. Select the volume you want to use (ensure it is in the **same Availability Zone** as your EC2 instance, e.g., `us-east-1b`).
3. Click **Actions** ➡️ **Attach volume**.
4. **Instance:** Click the box and select your running Nginx/Application instance ID.
5. **Device name:** Leave it at the default suggestion (e.g., `/dev/sdf` or `/dev/xvdf`). AWS Nitro instances will automatically translate this to an NVMe device interface standard.
6. Click **Attach volume**.

---

## 🗺️ Phase 2: Create the Filesystem Structure (Ubuntu Terminal)

Now that the "hardware" is plugged in, you need to format it. SSH into your EC2 instance and execute the following operational workflow.

### 1. Identify the New Raw Disk

Run your block device mapping tool to verify the OS sees the unformatted drive:

```bash
lsblk

```

* **What to look for:** You will see your primary disk (`nvme0n1` with its `p13`, `p14`, `p15` partitions), and a brand-new raw disk right below it named **`nvme1n1`** (with no partitions and no mount points listed).

### 2. Check if it already has a Filesystem

If this is a completely blank volume, it has no filesystem. Verify this by running:

```bash
sudo file -s /dev/nvme1n1

```

* **Expected output for a blank disk:** `/dev/nvme1n1: data` (If it says "data", it is completely empty and safe to format).

### 3. Create a Fresh ext4 Filesystem

Create the logical indexing layer directly on the raw disk:

```bash
sudo mkfs -t ext4 /dev/nvme1n1

```

---

## 📂 Phase 3: Mount the Volume to a Target Directory

To use this space, you must map it to a specific directory folder inside Linux.

### 1. Create the Mount Point Location

Let’s create a dedicated folder where you want to route data (for example, a secondary application storage directory or a custom logs directory):

```bash
sudo mkdir /mnt/vignan-data

```

### 2. Mount the Disk

Link the formatted disk volume directly to that new folder space:

```bash
sudo mount /dev/nvme1n1 /mnt/vignan-data

```

### 3. Verify the Active Filesystem Size

Run your structural storage inspection tool:

```bash
df -h

```

You will now see a brand-new, clean line item at the bottom of the matrix showing your newly attached storage capacity cleanly mounted and ready for file operations:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme1n1     20G   24M   19G   1% /mnt/vignan-data

```

---

## ⚡ Step 4: Make the Mount Persistent (Crucial Production Step)

If you stop or reboot your EC2 instance right now, Linux will forget this mount link. To make it permanent so it automatically hooks up on boot:

1. Backup your filesystem configuration table file:
```bash
sudo cp /etc/fstab /etc/fstab.bak

```


2. Find the unique **UUID** of your new disk volume:
```bash
sudo blkid | grep nvme1n1

```


*(Copy the string inside the quotes, e.g., `UUID="1234abcd-56ef..."`)*
3. Open the file: `sudo nano /etc/fstab` and append a new line entry at the very bottom:
```text
UUID=your-copied-uuid-here  /mnt/vignan-data  ext4  defaults,nofail  0  2

```


4. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`), then run `sudo mount -a` to test that the configuration line contains no syntax errors.