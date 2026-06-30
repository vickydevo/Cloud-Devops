*********************************************
# File System
*******************************************

A File System is a method used by an operating system (OS) to organize, store,
   retrieve, and manage data on storage devices like hard drives, SSDs, and USB drives. It defines how data is structured and accessed on a disk.

Key Functions of a File System:
------------------------------
    File Organization –     Manages how files and directories (folders) are stored.
    File Naming –       Defines how files are named and structured.
    Access Control –    Handles permissions and security settings.
    Storage Management – Allocates space efficiently for files.
    Metadata Management – Maintains information like file size, timestamps, and permissions.

Windows File Systems:
---------------------
    NTFS (New Technology File System) – Default for modern Windows OS, supports security permissions and large files.
    FAT32 (File Allocation Table 32) – Compatible with most devices but has a file size limit of 4GB.
    exFAT (Extended File Allocation Table) – Designed for external drives, supports larger file sizes.

Linux File Systems:
---------------------
    ext4 (Fourth Extended Filesystem) – Default for most Linux distributions, supports journaling.
    XFS – High-performance file system, good for large files.
    Btrfs (B-Tree File System) – Advanced file system with snapshot support.

*********************************************
# Linux File Structure
*******************************************
Linux follows a hierarchical file structure where everything is organized under the root (`/`) directory.

## **1. Root Directory (`/`)**
The top-level directory in Linux, containing all other directories and files.

## **1. Introduction to Linux File System**
The Linux file system is a structured way of organizing and storing data. It follows a hierarchical directory structure, starting from the root (`/`). Each directory serves a specific purpose, ensuring efficient system operations and file management.

---

## **2. Essential Directories in Linux**

### **2.1 `/bin` (Binary Executables)**
        - Stores essential command-line utilities and system binaries.
        - Commands available to all users.
        - **Examples:** `ls`, `cp`, `mv`, `cat`.

### **2.2 `/boot` (Bootloader & Kernel Files)**
        - Contains bootloader files, Linux kernel, and `GRUB` bootloader configurations.
        - **Bootloader:** A program that loads the OS into memory.
        - **Examples:** `vmlinuz-<version>`, `initrd.img-<version>`.

### **2.3 `/dev` (Device Files)**
        - Represents hardware devices as files.
        - **Examples:** `/dev/sda` (Hard drive), `/dev/tty1` (Terminal), `/dev/null` (Data discard).

### **2.4 `/etc` (Configuration Files)**
        - Stores system-wide configuration files and settings.
        - **Examples:** `/etc/passwd` (User accounts), `/etc/fstab` (File system mount points).

### **2.5 `/home` (User Home Directories)**
        - Contains personal directories for users.
        - **Example:** `/home/username/`.

### **2.6 `/lib` (Shared Library Files)**
        - Stores essential shared libraries required by system programs.
        - **Examples:** `libc.so.6` (C library), `ld-linux.so.2` (Dynamic linker).

### **2.7 `/media` (Removable Media Mount Point)**
        - Used for mounting external drives (USB, CDs, etc.).
        - **Example:** `/media/usb-drive/`.

### **2.8 `/mnt` (Temporary Mount Point)**
        - Temporary mounting location for filesystems.
        - **Example Command:** `sudo mount /dev/sdb1 /mnt`.

### **2.9 `/opt` (Optional Software Packages)**
    - Stores manually installed third-party applications.
    - **Examples:** `/opt/google/`, `/opt/oracle/`.

### **2.10 `/proc` (Process Information)**
        - Virtual filesystem with real-time system information.
        - **Examples:** `/proc/cpuinfo` (CPU details), `/proc/meminfo` (Memory usage).

### **2.11 `/root` (Root User Home Directory)**
        - Home directory for the root user.

### **2.12 `/sbin` (System Binaries)**
        - Stores administrative commands for system maintenance.
        - **Examples:** `shutdown`, `fdisk`, `iptables`.

### **2.13 `/srv` (Service Data Storage)**
        - Stores data for network services (e.g., web, FTP).
        - **Example:** `/srv/www/` for web server files.

### **2.14 `/sys` (Kernel System Information)**
        - Stores kernel-related system information.

### **2.15 `/tmp` (Temporary Files)**
    - Stores temporary system and application files.
    - Cleared upon reboot.

### **2.16 `/usr` (User Programs and Utilities)**
        - Contains user-installed software and utilities.
        - **Subdirectories:**
        - `/usr/bin/` → User command binaries.
        - `/usr/lib/` → Shared libraries.
        - `/usr/share/` → Documentation, icons, themes.

### **2.17 `/var` (Variable Data Storage)**
    - Stores frequently changing files (logs, mail, cache).
    - **Examples:** `/var/log/` (System logs), `/var/tmp/` (Temporary files).

*************************
User Management
***************************
Linux follows a hierarchical file structure where everything is organized under the root (`/`) directory.

## **1. Root Directory (`/`)**
The top-level directory in Linux, containing all other directories and files.

## **Connecting to an EC2 Instance via Command Line**
### **Home Paths for Users**
        - `ec2-user` → `/home/ec2-user`
        - `root` → `/root`
        - `devops` → `/home/devops`

### **User Management in Linux**
#### **1. Create a User**
```bash
useradd <username>
```
Example:
```bash
useradd devops   # For Amazon Linux  
useradd -ms /bin/bash devops  # For Ubuntu
```
- `-m` → Creates a home directory for the user (`/home/devops`).
- `-s /bin/bash` → Sets the default shell for the user to `/bin/bash`.

Verify the new user directory:
```bash
ls /home
```

#### **2. Set a Password**
```bash
passwd <username>
```
Example:
```bash
passwd devops
```

#### **3. View User Information**
Open `/etc/passwd` file:
```bash
cat /etc/passwd
```
Use `getent` to fetch user details:
```bash
getent passwd
```

### **Connecting to Servers Using a PEM/PPK File or Username & Password**
By default, AWS instances use key-based authentication (`.pem` or `.ppk`).

To enable password authentication:

## Using Password:
```bash
ssh user_name@remote_ip
ssh remote_ip   # (if remote user is same as local terminal user)
```

## Modify SSH configuration:
```bash
vi /etc/ssh/sshd_config
# Change PasswordAuthentication to yes
```

## Restart the SSH service for changes to apply:
```bash
systemctl restart sshd  # Amazon Linux
sudo service ssh restart  # Ubuntu (Check if it works properly)
```

## Deleting a User
```bash
userdel <username>
```
Example:
```bash
sudo userdel devops
```

# **Shell Script Task - 1**
### **Print Project Name, Script, Author, and Date**
#### **Script:**
```bash
#!/bin/bash
clear
echo "****************************************"
echo "Project Name : Education Sector"
echo "Script Name : Create a Directory and File"
echo "Author : Melky"
echo "Date : 11-March-2024  $(date)"
echo "****************************************"
```

This script prints project details, script information, author, and date.

