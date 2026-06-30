
---


# Guide: Expanding EBS Volume and Filesystem on Ubuntu

This guide explains how to increase the storage capacity of your EC2 instance without rebooting or losing data.

## 1. Increase Volume Size in AWS Console
Before running commands on the server, you must modify the "hardware" limit:
1. Log in to **AWS Console** > **EC2 Dashboard**.
2. Go to **Elastic Block Store** > **Volumes**.
3. Select your volume, click **Actions** > **Modify Volume**.
4. Change the size (e.g., from 20 to 30 GiB) and click **Modify**.

---

## 2. Identify the Partition to Expand
Run the following command to see your disk structure:
```bash
lsblk

```

**Look for:**

* The disk name (usually `nvme0n1`).
* The partition name (usually `nvme0n1p1`).
* Note that the disk size might show 30G, but the partition `nvme0n1p1` will still show 7G or 20G.

---

## 3. Expand the Partition

Use the `growpart` utility to tell the partition to use the newly added space.
*Note: There is a space between the disk name and the partition number.*

```bash
# Syntax: sudo growpart /dev/[DISK_NAME] [PARTITION_NUMBER]
sudo growpart /dev/nvme0n1 1

```

---

## 4. Resize the Filesystem

Even though the partition is now larger, the Ubuntu filesystem (ext4) needs to be stretched to fill that partition.

```bash
# Resize the root filesystem
sudo resize2fs /dev/nvme0n1p1

```

---

## 5. Verification

Check the disk usage again to confirm the new size is reflected in the `Size` and `Avail` columns.

```bash
df -h

```

**Expected Output:**
The `/dev/root` or `/` mount point should now show the full size you allocated in the AWS Console (e.g., 30G).

---

## Troubleshooting: "No space left" during resize

If your disk is so full that `growpart` cannot create temporary files, run these cleanup commands first:

```bash
# Remove unused Docker data
docker system prune -af

# Clear apt cache
sudo apt-get clean

# Remove Trivy cache (if applicable)
trivy image --reset

```



---
