







The classic high-level diagram of **Docker Client $\rightarrow$ Docker Host $\rightarrow$ Docker Registry** is a great way to understand how Docker works conceptually. However, when you look under the hood at the actual software engine running on your Ubuntu VM, the "Docker Host" is broken down into modular components: **Docker Daemon (dockerd), containerd, containerd-shim, and runc**.

This modular architecture exists because Docker transitioned to industry-standard container specifications (OCI) to make the ecosystem more modular, reliable, and secure.

Here is the breakdown of why the Server output contains these specific layers and what each component actually does inside your machine.

---

## The Real-World Breakdown of the Docker Server Layer

Instead of one monolithic application running your containers, Docker splits the responsibilities down the chain:

### 1. Docker Daemon (`dockerd`)

* **What it is:** The high-level orchestrator.
* **Why it's there:** When you type `docker run`, your Client talks directly to `dockerd`. The daemon handles API requests, manages high-level configurations, credentials, image building (`buildkit`), networks, volumes, and security policies.
* **The Catch:** It doesn't actually create or run containers anymore. It hands that job off down the line.

### 2. `containerd`

* **What it is:** The container lifecycle manager.
* **Why it's there:** Originally part of Docker, `containerd` was spun off as an independent, CNCF-graduated project (which is also used directly by Kubernetes via CRI). It manages the entire lifecycle of a container: pulling/pushing images, managing storage layers, and setting up network namespaces.
* **The Catch:** While it supervises containers, it *still* doesn't spawn the actual container process. It delegates that execution to a low-level runtime.

### 3. `runc`

* **What it is:** The low-level execution engine (OCI Runtime).
* **Why it's there:** `runc` is a lightweight, command-line tool built strictly to interact with the Linux kernel features that create isolation (like namespaces, cgroups, and seccomp profiles). It takes a standardized root file system and configuration file from `containerd`, talks to the kernel to spin up the container process, and then **immediately exits**.

### 4. `containerd-shim`

* **What it is:** The silent babysitter.
* **Why it's there:** Because `runc` exits as soon as the container starts, something needs to stick around to manage the container. The **shim** sits between `containerd` and the container process. It serves two crucial purposes:
1. It keeps the container's standard input/output streams (`stdin`, `stdout`, `stderr`) open even if the main Docker daemon or `containerd` restarts or crashes. This means **your containers keep running even during Docker upgrades.**
2. It reports the container's exit status back to `containerd` when it finally terminates.



---

## Summary of the Flow

When you run a container, the workflow passes down this chain:

$$\text{Docker Client} \xrightarrow{\text{API}} \text{dockerd} \xrightarrow{\text{gRPC}} \text{containerd} \xrightarrow{\text{Spawns}} \text{containerd-shim} \xrightarrow{\text{Executes}} \text{runc} \rightarrow \text{Container Process}$$

Your `docker version` output is showing you exactly this decoupled reality: `Engine` (`dockerd`), `containerd`, and `runc` are listed with their individual versions because they are separate binaries working together to keep your workloads safe and persistent!



You don’t see a version number for the **shim** because it doesn't run as a standalone, decoupled product with its own independent version cycle. Instead, the shim is built and distributed directly as an internal sub-component of **containerd**.

When you look at your version output:

```text
 containerd:
  Version:          2.2.2
  GitCommit:

```

Because the shim is packaged directly inside `containerd`, its version is implicitly the exact same (**v2.2.2** in your case).

If you log into your Ubuntu VM terminal and look at the actual binaries installed on your disk, you can see how closely they are tied together:

```bash
ls -l /usr/bin/containerd*

```

You will typically see files like `/usr/bin/containerd` and `/usr/bin/containerd-shim-v2`.

### Why isn't it broken out in the `docker version` output?

1. **It's a process engine, not a daemon:** `dockerd` and `containerd` run constantly in the background as system services (daemons). The shim is not a persistent system service; rather, a **new, individual shim process is spawned dynamically for every single container** you run. If you run 5 containers, you will see 5 separate `containerd-shim` processes running in your task manager (`ps aux | grep shim`).
2. **No independent configuration:** You never update, configure, or troubleshoot the shim by itself. When the Docker or `containerd` maintainers patch the shim, they release it as a new version of `containerd`.

If you ever need to verify exactly what version of the shim binary is sitting on your file system, you can query it directly via the Linux command line using the help flag:

```bash
containerd-shim-v2 -v

```

This will output the exact same codebase version matching your master `containerd` engine!