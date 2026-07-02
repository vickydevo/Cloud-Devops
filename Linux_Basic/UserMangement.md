Here is the complete, comprehensive `README.md` file updated to cover the entire end-to-end user lifecycle—from initial creation, group mapping, and privilege restriction, all the way to secure deletion and cleanup.

---

```markdown
# Linux User Lifecycle Management & Security Guide

This document serves as a production-grade reference manual for managing the entire lifecycle of Linux operating system users. It covers secure user creation, group provisioning, least-privilege `sudo` restriction, auditing, and clean user decommissioning.

---

## 1. User Account Architecture & UID Tiers

Linux identifies accounts using unique numerical **UIDs (User IDs)** rather than usernames. Understanding these tiers ensures correct permission placement:

| User Type | Default UID Range | Scope of Privilege |
| :--- | :--- | :--- |
| **Superuser (`root`)** | `0` | Absolute system control. Bypasses all discretionary access and security barriers. |
| **System Accounts** | `1 - 999` | Non-interactive accounts used to run system services (e.g., `mysql`, `nginx`, `systemd`). |
| **Standard Users** | `1000+` | Interactive human or application accounts (e.g., `ubuntu` is `1000`, `dev` is `1001`). Confined to personal home directories. |

---

## 2. Phase 1: User Provisioning (Creation)

There are two primary methods to create a user in Ubuntu/Debian systems: interactive and non-interactive.

### Method A: Interactive Provisioning (Recommended for Admins)
The `adduser` command is a high-level Perl script wrapper that automatically creates a home directory, sets the default shell, assigns a UID, and prompts for password configuration interactive mode.
```bash
sudo adduser dev

```

### Method B: Non-Interactive Provisioning (Recommended for Automation/CI-CD)

The low-level `useradd` binary creates the user skeleton. Flags must be explicitly defined.

```bash
sudo useradd -m -s /bin/bash dev
sudo passwd dev

```

* `-m`: Forces the creation of the user's home directory (`/home/dev`).
* `-s /bin/bash`: Explicitly sets Bash as the default interactive shell environment instead of `/bin/sh`.

---

## 3. Phase 2: Group Management & System Access

Groups allow multiple users to share common security privileges (like accessing the Docker API socket).

### Viewing Group Assignments

To verify what access permissions a user currently holds:

```bash
# Check group memberships for the current user
groups

# Check group memberships for a specific user
groups dev
id dev

```

### Granting Access (Adding Users to Groups)

Use the `usermod` utility to append groups. Always combine the `-a` (append) flag with `-G` (groups) to prevent accidentally overwriting the user's existing secondary groups.

```bash
# Grant 'dev' access to run Docker containers by adding them to the docker group
sudo usermod -aG docker dev

# Refresh the shell group context immediately without logging out
newgrp docker

```

---

## 4. Phase 3: Enforcing Least Privilege via `/etc/sudoers`

To grant a restricted user access to run **only** specific administrative commands without handing over full, unrestricted `root` control, map targeted execution rules.

### Core Safeguard Rules

* **Always Use Absolute Paths:** Never write `apt-get`. Write `/usr/bin/apt-get`. This prevents users from altering their local execution `$PATH` variable to execute malicious binaries masked as system tools.
* **Always Use `visudo`:** Never edit `/etc/sudoers` directly with a standard text editor. `visudo` validates your file syntax before writing changes to disk. A single typo can lock all administrative users out of `sudo` privileges permanently.

### Step-by-Step Configuration Workflow

1. **Locate Binary Paths:** From your administrative account (`ubuntu`), locate the exact binary files:
```bash
ubuntu@vm:~$ which apt-get       # Returns: /usr/bin/apt-get
ubuntu@vm:~$ which systemctl     # Returns: /usr/bin/systemctl

```


2. **Open the Sudo Matrix:** Open the secure policy editor:
```bash
sudo visudo

```


3. **Append the Rule Profile:** Navigate to the bottom of the file and insert the constraint profile.
```text
# Allows user 'dev' to execute only metadata updates and docker restarts as root
dev ALL=(ALL:ALL) /usr/bin/apt-get update, /usr/bin/systemctl restart docker

```


*(Optional: Prepend `NOPASSWD:` to the paths if the commands need to run inside non-interactive automated maintenance scripts).*

### Verification of Enforcement

```bash
# Matches exactly -> Allowed
dev@vm:~$ sudo apt-get update

# Argument variation -> Blocked
dev@vm:~$ sudo apt-get install nginx
Sorry, user dev is not allowed to execute '/usr/bin/apt-get install nginx' as root on vm.

```

---

## 5. Phase 4: Auditing & Identity Tracking

To maintain operational integrity, regularly inspect active users and active groups.

```bash
# List all system users, their UIDs, and default shell configurations
cat /etc/passwd

# Isolate standard human users from system accounts
awk -F: '$3 >= 1000 {print $1, $3, $6}' /etc/passwd

# Review system authentication logs to see who used sudo and when
sudo tail -f /var/log/auth.log

```

---

## 6. Phase 5: Decommissioning & Deletion

When an account is no longer required, it should be cleanly decommissioned to prevent orphaned permissions and dangling configuration files.

### Step 1: Revoke Group Access Privileges (Partial Deprovisioning)

If the user should remain on the system but lose access to specific resources (like Docker or Sudo), explicitly remove them from the target group:

```bash
sudo gpasswd -d dev docker

```

### Step 2: Lock the Account (Temporary Suspensions)

If an employee leaves temporarily, lock their password to prevent logins without deleting their file metadata:

```bash
# Lock account
sudo passwd -l dev

# Unlock account
sudo passwd -u dev

```

### Step 3: Complete User Destruction (Permanent Removal)

When deleting a user entirely, you must decide whether to retain or purge their physical asset footprint.

**Option A: Delete user BUT preserve their files for audit/backup:**

```bash
sudo userdel dev

```

*(The user is removed from `/etc/passwd`, but `/home/dev` remains intact. These files will now show an unmapped numerical UID owner).*

**Option B: Deep purge (Delete user AND erase their entire home directory and mail spool):**

```bash
# Using standard low-level tools
sudo userdel -r dev

# Using high-level interactive wrappers
sudo deluser --remove-home dev

```

---

## Summary Cheat Sheet Workflow

```text
[ adduser dev ] ----------> [ usermod -aG ] ----------> [ visudo ] ----------> [ userdel -r ]
  (Create account)             (Assign Group)          (Restrict Sudo)         (Purge Account)

```

```

```