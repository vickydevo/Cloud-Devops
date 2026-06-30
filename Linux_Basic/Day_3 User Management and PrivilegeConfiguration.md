# Different IP addresses (Public IP, Private IP & Elastic IP)
--------------------------------------------------------------

**Public IP Address:** Temporary and automatically assigned by AWS for internet-facing instances; released when the instance is stopped.

**Private IP Address:** Used for internal network communication within a VPC; remains with the instance even when stopped.

**Elastic IP Address:** A static public IP that can be manually allocated and reassigned; persists across instance reboots and can be associated with different instances as needed.

Here's a detailed **README** file explaining how to **connect to an EC2 instance using VS Code** by editing the SSH configuration file:

---

# 🖥️ Connect to an AWS EC2 Instance Using VS Code

This guide walks you through connecting to your AWS EC2 instance from **Visual Studio Code (VS Code)** using an SSH key and configuration.

---

## ✅ Prerequisites

Make sure the following are ready before starting:

1. ✅ An AWS EC2 instance is **running**.
2. ✅ You have a `.pem` private key file downloaded (e.g., `VM.pem`).
3. ✅ You have **Visual Studio Code** installed.
4. ✅ Install the **Remote - SSH extension** in VS Code.
5. ✅ You know your EC2 **public DNS** (e.g., `ec2-65-2-39-249.ap-south-1.compute.amazonaws.com`).
6. ✅ Your `.pem` file has the correct permissions (read-only).

---

## 🛠️ Step-by-Step Guide

### 1. 📥 Install the Remote - SSH Extension in VS Code

1. Open VS Code.
2. Go to the Extensions tab (`Ctrl + Shift + X`).
3. Search for `Remote - SSH` and install it.

---

### 2. 🔐 Save Your `.pem` File

Move your `.pem` file (e.g., `VM.pem`) to a known path such as:

```
C:\Users\VIGNAN\Downloads\VM.pem
```

Make sure this file has **read-only permissions**:
- Right-click on `VM.pem`
- Go to **Properties > Security > Advanced**
- Ensure only your user has permission, and it is **read-only**

---

### 3. 📝 Edit the SSH Config File

1. Open the config file (or create it if it doesn't exist):

```
C:\Users\VIGNAN\.ssh\config
```

> You can open it with Notepad or VS Code itself.

2. Add the following configuration:

```
Host sudheer
    HostName ec2-65-2-39-249.ap-south-1.compute.amazonaws.com
    IdentityFile C:/Users/VIGNAN/Downloads/VM.pem
    User ec2-user
```

> ⚠️ Note: Use forward slashes `/` in the `IdentityFile` path.

---

### 4. 💻 Connect from VS Code

1. Open VS Code.
2. Press `F1` or `Ctrl + Shift + P` to open the command palette.
3. Type `Remote-SSH: Connect to Host...` and press Enter.
4. Select the host name you defined (`sudheer`).
5. VS Code will now connect to your EC2 instance via SSH.

---

### 5. 📂 Open Folders and Work Remotely

Once connected:
- You can browse files on the EC2 machine.
- You can open a terminal (`Ctrl + ~`) and run commands directly on the instance.
- You can install server-side extensions if prompted.

---

## 🧼 Optional: Troubleshooting Tips

- 🔁 If connection fails, try restarting VS Code and your EC2 instance.
- 🔐 Make sure port **22** is open in your EC2 **Security Group** inbound rules.
- 🛑 Do **not** share your `.pem` file publicly.

---

## ✅ Example Output in VS Code Terminal

```bash
[09:41:15.738] > Connecting to SSH Host: sudheer ...
[09:41:17.201] > Connected to ec2-user@ec2-65-2-39-249.ap-south-1.compute.amazonaws.com
```

You’re now ready to work on your EC2 instance right from VS Code!

---

Let me know if you want me to save this as a downloadable README file or markdown version.


# User Management and Privilege Configuration
---------------------------------------------

## 1. Create a User and Install Git

To create a user and install Git using `yum` or `apt`:

```sh
sudo useradd devops
sudo useradd -ms /bin/bash devops # For Ubuntu servers
sudo passwd devops  # Set a password for the user
```

To install Git:
```sh
sudo yum install git tree -y  # For RHEL-based systems
sudo apt install update -y   # For Debian-based systems
```

### Change the Current Shell Temporarily

```sh
bash   # Switch to Bash
sh     # Switch to sh
zsh    # Switch to Zsh (if installed)
exit   # Return to previous shell or press Ctrl+D
```

### Check Available Shells

```sh
cat /etc/shells
```

Example output:
```
/bin/sh
/bin/bash
/bin/dash
/bin/zsh
```


## 2. Grant Root Privileges to a Non-root User

If you encounter the error:
> devops is not in the sudoers file.

Edit sudoers:
```sh
sudo visudo
```
Add under `# User privilege specification`:
```sh
devops ALL=(ALL:ALL) NOPASSWD:ALL
```


## 3. List Users and Groups

### Show all users:
```sh
sudo cat /etc/passwd
getent passwd
```

### Show all groups:
```sh
sudo cat /etc/group
getent group
```

### Count total groups:
```sh
getent group | wc -l
```


## 4. Understanding `wc` Command

```sh
wc file.txt       # lines, words, bytes
wc -l file.txt    # only lines
```


## 5. Using `tee` Command

```sh
nl file1 | tee file1temp.txt && mv file1temp.txt filerenamed
```

- `nl` → Number lines
- `tee` → Duplicates output to a file


## 6. Group Management

### Create a new group:
```sh
sudo groupadd admins
```

### Add user to groups:
```sh
sudo usermod -aG admin devops
sudo usermod -aG wheel devops
```

### Set primary group:
```sh
sudo useradd -g admin devops
```

### Add user to multiple groups:
```sh
sudo useradd -G admin tester
```

### Check user group membership:
```sh
groups devops
```

Example output:
```
devops : devops admin
```


## Directory Structure Example
```sh
touch Linux/file1
mkdir -p Linux/amazon/root/ec2
cd Linux/amazon && touch file2
cd root && touch file3 && cd ec2 && touch file4
tree
```

Expected Output:
```
.
└── Linux
    ├── amazon
    │   ├── file2
    │   └── root
    │       ├── ec2
    │       │   └── file4
    │       └── file3
    └── file1
```


## 7. Manage Sudoers Configuration

### Add to sudoers file:
```sh
vi /etc/sudoers.d/admins
```

Add content:
```sh
# Created by Vignan on March 11, 2024

# Group rules for admins
%admins ALL=(ALL) NOPASSWD:ALL
```


## 8. Checking Group Membership

```sh
getent group wheel
getent group devops
```

Example:
```
devops:x:1002:arya,keerthi
```

### Remove user from group:
```sh
sudo gpasswd -d devops wheel
```


## 9. View Encrypted Passwords

```sh
sudo cat /etc/shadow
```


# Task - 2
----------

1. Create a directory with your name inside your last name directory  
2. Create a file inside your name directory and add text about yourself in 4 lines using redirection (no editor)  
3. Print the content of the file  
4. Use `sleep` command to delay execution  
5. Add comments for each step  


## Script

```bash
#!/bin/bash
clear
# Display Script Name, Author, Date at the top of the script
echo "###################################################"
echo "#   Project Name : Education sector               #"
echo "#   Script Name  : Create dir and file            #"
echo "#   Author       : Vignan                         #"
echo "#   Created on   : $(date)     #"
echo "###################################################"
sleep 3
echo "********************************************************************"
echo "creating training directory inside synchro.......... "
echo "*******************************************************************"
sleep 2
mkdir -p synchro/trainings
sleep 2
echo "*************************************************************************"
echo "creating a file and adding text without entering into file... "
echo "*******************************************************************"
sleep 2
echo "Devops, Security Analyst, junior software Developer" > ./synchro/trainings/info.txt
sleep 2
clear
echo "*******************************************************************"
echo " printing the text that was written in info.txt  ........"
echo "*******************************************************************"
cat synchro/trainings/info.txt
```

---