# Deep Dive: Under the Hood of the Docker Server Layer

When looking at the classic high-level architecture (**Docker Client → Docker Host → Docker Registry**), it's easy to view the "Docker Host" as a single monolithic application. However, on a modern Linux system (like an Ubuntu VM), the Docker engine is broken down into highly modular, decoupled components conforming to Open Container Initiative (OCI) industry standards.

This design ensures high reliability, security, and allows you to update the core Docker daemon without dropping your running containers.

---

## 🏗️ Architecture Components

Instead of one massive process, Docker splits responsibilities down a specialized chain:


---

### 🔄 The Image & Container Workflow

To see exactly where the `pull` happens versus where the `run` happens, here is the updated layout:

```
[ Docker Client ] ────► (User types: docker pull or docker run)
       │
       ▼ (REST API)
[  dockerd  ] 
       │
       ▼ (gRPC)
[ containerd ] ───► [ Docker Registry ] (containerd PULLS/PUSHES the image layers)
       │
       ├─► (Unpacks layers into a root filesystem)
       ├─► (Generates the OCI config.json)
       │
       ▼ (Spawns)
[ containerd-shim ] 
       │
       ▼ (Invokes short-lived tool)
[   runc    ] ───► (Configures kernel Cgroups/Namespaces and exits)
       │
       ▼
[ Container Process ] (Monitored by the shim)

```

### 1. Docker Daemon (`dockerd`)
* **Role:** High-Level Orchestrator
* **Function:** This is the persistent background service that talks directly to the Docker CLI Client via REST API. It manages high-level tasks like API requests, authentication, image building (`buildkit`), complex networking, volumes, and security policies.
* **Note:** `dockerd` does not actually create or run containers anymore. It delegates that execution further down the stack.

### 2. Containerd (`containerd`)
* **Role:** Container Lifecycle Manager
* **Function:** Originally part of Docker, `containerd` is now an independent, CNCF-graduated project (also used by Kubernetes via CRI). It supervises the entire lifecycle of your container environments. It pulls/pushes images, manages low-level storage layers, and manages network namespaces. 
* **Note:** While it supervises containers, it still does not spawn the actual container process. It hands that task over to a low-level runtime.

### 3. Runc (`runc`)
* **Role:** Low-Level Execution Engine (OCI Runtime)
* **Function:** A lightweight, command-line tool built strictly to interact with native Linux kernel isolation features. It reads a standardized configuration file (`config.json`) and root file system provided by `containerd`, makes the system calls to create **Namespaces** and **Cgroups**, spawns the container process, and then **immediately exits**.

### 4. Containerd-Shim (`containerd-shim`)
* **Role:** The Silent Babysitter
* **Function:** Because `runc` exits immediately after starting the container, a temporary process is needed to monitor it. The **shim** sits between `containerd` and the running container process, serving two critical purposes:
  1. It hooks into the container's standard input/output streams (`stdin`, `stdout`, `stderr`), ensuring **your containers stay running even if `dockerd` or `containerd` crashes or gets restarted during an upgrade**.
  2. It reports the container’s exit code back to `containerd` when the workload finishes.

---

