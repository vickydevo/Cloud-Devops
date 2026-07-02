# Container Images & Lifecycle Management

This repository documents the core concepts of working with Docker image registries, auditing image quality, and managing container lifecycles based on practical CLI exploration.

---

## 1. The Container Lifecycle Workflow

```text
[ Image Registry ]  --->  ( Pull Image )  --->  [ Local Image ]  --->  ( Run Container )  --->  [ Active Container Process ]

```

A Docker container is simply a running instance of a static container image. The quality, configuration, and security of that image directly dictate how your container behaves.

---

## 2. Image Registries: Trust & Verification

Container images are hosted in registries. Choosing where you source your images is critical for security and stability ("Should I use this image, or shouldn't I?").

### Registry Types

* **Public Registries:** Docker Hub (`docker.io`), Red Hat Ecosystem Catalog (`registry.access.redhat.com`), Quay.io.
* **Cloud Platform Registries:** AWS ECR, Google Artifact Registry, Azure CR.

### Official vs. Unofficial Images

* **Official Images:** Maintained by upstream open-source communities or vetted vendors. They follow security best practices (e.g., automated vulnerability patching, minimal layers).
* *Example:* `docker pull docker.io/library/httpd`
* *Example:* `docker pull nginx:latest`


* **Unofficial / User Images:** Created by independent individuals or third parties. They may contain custom configurations, outdated dependencies, or unexpected base environments.
* *Example:* `docker pull vignan91/spring-test:30aug`



> ⚠️ **Critical Lesson:** **Never rely solely on an image's name.** An image named `spring-test` might actually wrap a Red Hat Perl builder base image instead of a Java/Spring Boot environment. Always audit and verify.

---

## 3. Auditing and Verifying an Image

Before deploying an image to production, you must verify its contents using **Image Auditing Metrics**:

1. **Known Ports:** Which ports are explicitly exposed by the image creator?
2. **Execution Process:** What binary executes at startup (`CMD` / `ENTRYPOINT`)?
3. **User Privileges:** Does the image run as a risky `root` user or a secure `non-root` user (e.g., User ID `1001`)?

### Inspection Techniques

Use `docker inspect` to pull raw JSON metadata from an image or a running container, combined with standard Linux filters like `grep`.

#### Filter Exposed Ports:

```bash
docker inspect vignan91/spring-test:30aug | grep -i exposed -A 4

```

#### Analyze Container Logs:

If a container terminates unexpectedly right after launch, inspect its logs to see what its internal startup scripts executed:

```bash
docker logs <container-id>

```

---

## 4. Docker Command Cheat Sheet

Below is the categorized breakdown of the commands used during this exploration session.

### Container Inspection & Diagnostics

```bash
# Check status of all local containers (active and exited)
docker ps -a

# Fetch detailed metadata of an image or container
docker inspect vignan91/spring-test:30aug
docker inspect registry.access.redhat.com/ubi8/perl-526:1782869519

# View stdout/stderr console output from a specific container
docker logs fe5800d2814a

```

### Container Lifecycle Management

```bash
# Run a container in detached (background) mode
docker run -d --name two-spring vignan91/spring-test:30aug
docker run -d --name box-redhat registry.access.redhat.com/ubi8/perl-526:1782869519

# Forcefully remove a container by short-ID
docker rm fe58

```

### Image Management

```bash
# List all locally cached images
docker images

# Delete an image from local storage
docker rmi registry.access.redhat.com/ubi8/perl-526:1782869519

```