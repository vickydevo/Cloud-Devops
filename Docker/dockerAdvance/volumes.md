# Advanced Docker Volume Management & NFS Shared Storage Setup

This guide walks you through the comprehensive life cycle of container data management. We will explore how container mutations are tracked, how to implement storage restrictions, how to map multiple local paths simultaneously, and how to configure a multi-node shared Network File System (NFS) volume from scratch.

---

## 1. Tracking Container Mutations (`docker diff`)

When you run a container without explicit volumes, any additions, deletions, or edits occur inside the container's temporary writable layer.

### Where is the Writable Layer Stored?

Docker tracks these files inside your host system at:
`/var/lib/docker/overlay2/<container-specific-id>/`

### Monitoring File Changes

You can track what has changed since the container image initialized using the `docker diff` command. The terminal labels mutations with three flags:

* **`A`**: Appended (File or directory added)
* **`C`**: Changed (File content modified)
* **`D`**: Deleted (File removed)

```bash
# Example check on a running container named boxone
docker diff boxone

```

> **Why use Volumes instead of backing up `/var/lib/docker`?**
> While you technically *can* back up raw directories within `/var/lib/docker`, it is highly discouraged. Writable layers are tightly bound to the container runtime state. If you want to save a structural environment shift, build a new image using a `Dockerfile` or `docker commit`. If you want to keep data (like databases or uploads), abstract it cleanly into a **Docker Volume**.

---

## 2. Advanced Local Volume Topologies

Docker allows you to enforce strict storage constraints and couple multiple distinct storage units to a single container instance.

### Limiting Storage Capacity on a Local Volume

By default, a standard Docker volume expands until it fills the host disk. If you need to enforce hard storage quotas on production nodes, leverage `tmpfs` limits or point the device options directly toward dedicated underlying block partitions:

```bash
# Creating a storage-restricted 2 Gigabyte volume mapped to an underlying disk partition
docker volume create checkone --opt type=ext4 --opt device=/dev/sda2 --opt o=size=2G

# Verify the constraints
docker inspect volume checkone

```

### Attaching Multiple Volumes & Enforcing Read-Only Limits

You can scale data isolation by mapping multiple logical volumes into independent target paths within a single container execution.

The configurations below demonstrate how to provision high-performance web servers (`httpd` and `nginx`) sharing a static web payload volume in **Read-Only (`ro`)** mode, while writing runtime diagnostic traces into independent log volumes.

```bash
# Apache HTTPD Instance Setup
docker run -d --name boxone --restart always \
  --mount source=webdata,target=/usr/local/apache2/htdocs,ro \
  --mount source=weblogs,target=/usr/local/apache2/logs \
  httpd:latest

# Nginx Instance Setup
docker run -d --name boxtwo --restart always \
  --mount source=webdata,target=/usr/share/nginx/html,ro \
  --mount source=weblogs,target=/var/log/nginx \
  nginx:latest

```

---

## 3. Step-by-Step Shared Volume Setup via NFS

To scale across multiple independent physical cluster nodes, you need multi-host network storage. Here is how to bind your initialized `10 GiB` storage drive partition (`/dev/sdb1`) on your **Storage Server** and mount it seamlessly as a network volume inside **Docker Host Nodes**.

```
+-----------------------------------+               +-----------------------------------+
|       NFS STORAGE SERVER          |               |          DOCKER CLIENT HOST       |
|    (IP: 192.168.146.128)          |               |         (melky-VMware Node)       |
|                                   |               |                                   |
|  [ /dev/sdb1 ] ---> /mydata       |  (NFS Export) |  [ Docker NFS Volume ]            |
|  (Formatted Ext4, Exported Share) |==============>|  --opt o=addr=192.168.146.128     |
+-----------------------------------+               +-----------------------------------+

```

### Step #1: Mount and Prepare Storage on the NFS Server

Run these commands on your dedicated target storage node (`root@storage`):

```bash
# 1. Format the partitioned raw block storage 
mkfs.ext4 /dev/sdb1

# 2. Build the dedicated file attachment anchor target
mkdir /mydata

# 3. Mount the partition permanently via file systems table configuration
echo 'UUID="28d8267c-545f-4550-8dac-f759264d1ad6" /mydata ext4 defaults 0 0' >> /etc/fstab
mount -a
systemctl daemon-reload

# 4. Provision the Kernel NFS Framework kernel components
apt update && apt install nfs-kernel-server -y

# 5. Authorize client subnets inside the network export permissions file
echo '/mydata *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports

# 6. Apply exports configurations and restart active listener services
exportfs -ra
systemctl restart nfs-kernel-server
systemctl enable nfs-kernel-server

```

### Step #2: Verify & Connect the Docker Volume Client Node

Log into your Docker runtime machine (`melky-VMware`) to link the remote asset.

```bash
# 1. Install standard client-side system protocols 
sudo apt install nfs-common -y

# 2. Verify network visibility to ensure your storage server export is active
showmount -e 192.168.146.128

```

Now, construct the live production Docker Volume using the integrated client-side NFS storage driver instructions:

```bash
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.146.128,rw,noatime,nodiratime \
  --opt device=:/mydata \
  shared_nfs_volume

```

### Step #3: Deploy Containers Against the Shared Cluster Volume

Once defined, your multi-node cluster can attach to this target asset effortlessly. Any node reading from or writing to this mount points directly back to the physical SSD array on the storage engine machine.

```bash
# Run a container mapping the distributed network partition
docker run -d --name global-web-worker \
  --restart always \
  --mount source=shared_nfs_volume,target=/usr/share/nginx/html \
  nginx:latest

```

---

## 4. Detaching and Cleaning Up Volumes

Docker will never automatically clear active physical structural dependencies or wipe local block data files when an instance shuts down.

To safely tear down your structures without stranding unallocated volumes on disk, follow this sequence:

```bash
# 1. Gracefully terminate and wipe the existing container instance
docker rm -f global-web-worker

# 2. Clear out the target network volume declaration
docker volume rm shared_nfs_volume

# 3. Optional: Prune unused dangling storage networks globally
docker volume prune -f

```