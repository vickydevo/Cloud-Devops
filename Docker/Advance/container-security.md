Based on the terminal logs and concepts you provided, here is a comprehensive `README.md` file. It explains the core concepts of Container Security demonstrated in your output, including process namespaces, container lifecycle, the dangers of running as `root`, and Linux capabilities.

---

```markdown
# Container Security & Process Isolation Lab

This repository contains notes, explanations, and observations regarding Docker container security, process spaces, user identification, and the underlying principle of least privilege.

---

## 📋 Table of Contents
1. [Process Isolation & Namespaces](#1-process-isolation--namespaces)
2. [Container Lifecycle (PID 1)](#2-container-lifecycle-pid-1)
3. [The Danger of Running as Root](#3-the-danger-of-running-as-root)
4. [What is Sudo?](#4-what-is-sudo)
5. [Linux Capabilities (`capsh`)](#5-linux-capabilities-capsh)
6. [Security Best Practices](#6-security-best-practices)

---

## 1. Process Isolation & Namespaces

In your terminal log, running `ps -ef` inside the `httpd` container yielded only a few lines:

```bash
UID         PID    PPID  C STIME TTY        TIME CMD
root          1       0  0 13:12 ?        00:00:00 httpd -DFOREGROUND
www-data      8       1  0 13:12 ?        00:00:00 httpd -DFOREGROUND

```

### Why can't the container see the host processes?

Docker uses Linux **Namespaces** to isolate resources. Specifically, the **PID Namespace** creates a sandboxed process tree for the container.

* The container thinks its primary process (`httpd`) is **PID 1** (the root of all processes).
* In reality, on the actual host virtual machine (VM), this process has a completely different, much higher PID (e.g., PID 14234).
* This ensures that even if a container is compromised, the attacker cannot see or directly interact with processes running on the host or in other containers.

---

## 2. Container Lifecycle (PID 1)

When you executed this command:

```bash
docker run -it --name box1 lovelearnlinux/webserver:v1 sleep 30

```

The container exited automatically after 30 seconds.

### Key Takeaway:

A container only stays alive as long as its **PID 1** process is running.

* By overriding the default command with `sleep 30`, `sleep` becomes PID 1.
* As soon as the 30 seconds expire, PID 1 terminates, and Docker immediately shuts down the container.

---

## 3. The Danger of Running as Root

In your `box1` container, running `id` returned:

```bash
uid=0(root) gid=0(root) groups=0(root)

```

By default, unless specified otherwise in the `Dockerfile`, containers run as the `root` user.

### Why is this a major security problem?

1. **Shared Kernel:** Containers share the host operating system's kernel. The `root` user inside a container has UID `0`. The `root` user on your host VM *also* has UID `0`.
2. **Container Breakout:** If an attacker exploits a vulnerability in your web application (like Apache `httpd`) and drops into a shell, they are instantly `root`. If they manage to find a kernel vulnerability to break out of the container (Container Escape), they will automatically have full `root` administrative access to your entire Host VM.

### The Correct Way (Example: Red Hat UBI Image)

When you ran Red Hat's Universal Base Image (`box2`), you saw a safer implementation:

```bash
bash-5.1$ id
uid=1001(default) gid=0(root) groups=0(root)

```

Red Hat explicitly drops privileges in their image architecture. Even if this container is compromised, the hacker is restricted to a low-privileged user space (`uid=1001`), drastically reducing the risk of a host machine takeover.

---

## 4. What is Sudo?

`sudo` stands for **Superuser Do**.

On a standard Linux system (like your VM), normal users are heavily restricted to protect system files. When you created a new user using your command:

```bash
sudo useradd -ms /bin/bash dev

```

You used `sudo` to temporarily elevate your privileges to execute an administrative task (creating a user and their home directory).

* **Inside a container:** You should generally *never* install `sudo`. A container should do one thing well (e.g., run a web server). If a containerized process needs root permissions to start (like binding to port 80), it should drop down to a non-root user (like `www-data` or `apache`) immediately after initialization.

---

## 5. Linux Capabilities (`capsh`)

To inspect what privileges a process actually possesses, Linux uses **Capabilities**. Traditionally, Linux split privileges into two categories: *Root* (can do everything) and *User* (can do nothing administrative).

Capabilities split these massive "root privileges" into dozens of granular micro-permissions.

You can inspect these using the command:

```bash
capsh --print

```

### Why this matters for Container Security:

By default, Docker drops dangerous capabilities (like `CAP_SYS_ADMIN` or `CAP_SYS_RAWIO` which allows direct hardware access) even for the `root` user inside a container.

If you want to harden a container further, you can explicitly strip away more capabilities when launching it:

```bash
# Example: Running a container without the ability to change file ownerships
docker run --cap-drop=CHOWN -d httpd:latest

```

---

## 6. Security Best Practices Summary

* ❌ **Never run container processes as root (UID 0)** if it can be avoided. Always declare a non-root `USER` in your `Dockerfile`.
* ❌ **Do not use the `--privileged` flag** when running containers unless absolutely necessary, as it bypasses all namespace and capability isolation.
* **Keep images minimal:** Notice how `ps` wasn't installed in the official `httpd` image initially? That is intentional. Fewer tools installed means a smaller attack surface for hackers.

```

---
*Note: I fixed a tiny typo in your `useradd` command string inside the documentation (`-ms dev /bin/bash` changed to `-ms /bin/bash dev`) to ensure it represents valid Linux syntax for your future reference!*

```