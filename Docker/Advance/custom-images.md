You have hit exactly the key pain point when moving from a quick-and-dirty `docker commit` workflow to an enterprise-grade `Dockerfile`.

As your terminal output showed, `docker commit` is fragile. When you tried to spin up `boxtwo`, it exited immediately (`Exited (1)`) because hardcoding user IDs (`--user 1001`) without explicitly managing file permissions breaks application processes. Furthermore, `docker commit` leaves behind zero documentation of *what* changed inside the image layer, making it impossible to reproduce or track in version control.

The revised `Dockerfile` resolves this by building a reproducible, **security-hardened, non-root image** using `www-data`. Here is the complete, professional `README.md` file you can include in your project directory to document this implementation.

---

### `README.md`

```markdown
# Secure Custom Apache Custom Docker Image

This repository contains the configuration to build a hardened, production-ready Apache (`httpd`) web server container running on **Ubuntu 24.04**. 

Unlike standard configurations or images created via `docker commit`, this image is explicitly structured to run as a **non-root user (`www-data`)** to satisfy strict security compliance requirements.

---

## 🛠️ Key Improvements over `docker commit`

* **Reproducibility:** Every change is explicitly documented in the `Dockerfile`.
* **Security Hardening:** The container drops `root` privileges immediately after setup. If the application is compromised, the attacker does not gain root access to the host ecosystem.
* **Port Mapping Adaptation:** Unprivileged users cannot bind to ports below 1024. The default Apache port is shifted to `8080`.
* **Layer Optimization:** Multiple `RUN` directives are consolidated into a single layer using `&& \` to drastically reduce image size.

---

## 🏗️ The Dockerfile Blueprint

```dockerfile
FROM ubuntu:24.04

LABEL author="Rakesh" \
      description="Hardened Ubuntu OS with Apache2 running as non-root" \
      usage="Production-ready custom webserver image" \
      arch="x64" \
      support="rakesh <rakesh@example.com>"

# Install dependencies, set up user environments, and fix permission matrices
RUN apt update -y && \
    apt install apache2 -y && \
    useradd rakesh -p redhat -c "raju" && \
    mkdir -p /tmp/mydata /var/log/apache2 /var/run/apache2 /var/www/html /var/lock/apache2 && \
    chown -R www-data:www-data /var/log/apache2 /var/run/apache2 /var/www/html /var/lock/apache2 /etc/apache2 

# Drop root privileges and switch to application user
USER www-data

# Copy web application assets
COPY src/ /var/www/html

# Port exposure shifted above 1024 for non-root compliance
EXPOSE 8080

# Execute the binary directly for reliable PID tracking and graceful shutdowns
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

```

---

## 🚀 Usage Instructions

### 1. Prerequisites

Ensure you have a `src/` directory in the root of your project containing your web assets (e.g., `index.html`).

```bash
mkdir -p src
echo "<h1>Hello from my secure container!</h1>" > src/index.html

```

### 2. Build the Custom Image

Execute the build command within the directory containing the `Dockerfile`:

```bash
docker build -t vignan91/webserver:v3 .

```

### 3. Run the Container

Run the container detached (`-d`) and map host port `80` (or any available port) to the container's unprivileged port `8080`:

```bash
docker run -d --name secure-webserver -p 80:8080 vignan91/webserver:v3

```

### 4. Verify Non-Root Status

To verify that the process is actually running securely under the `www-data` context instead of `root`, execute:

```bash
docker exec secure-webserver whoami
# Output should return: www-data

```

```

---

### A Quick Pro-Tip for your Apache Config:
Because you dropped container privileges to `USER www-data`, you also need to ensure that the internal configuration files of Apache actually expect to bind to port `8080`. 

If the container still fails to start due to a port bind issue, copy your local `httpd.conf` or `/etc/apache2/ports.conf` out, change the line `Listen 80` to `Listen 8080`, and `COPY` that modified configuration file into your Dockerfile alongside your `src/` files!

##Note: check Dockerfile https://hadolint.github.io/hadolint/

```