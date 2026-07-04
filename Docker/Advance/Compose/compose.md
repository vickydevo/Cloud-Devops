# Docker Compose & Volume Management Guide

Docker Compose is a tool for defining and running multi-container applications. It simplifies the management of your application stack by using a single YAML configuration file to define services, networks, and volumes. With a single command, you can create and start all the services defined in your configuration.

## Key Features
- **Environment Agnostic:** Works across development, testing, staging, CI/CD pipelines, and production.
- **Unified Lifecycle:** Single-command control over complex multi-container stacks.
- **Native Orchestration:** Simplifies container networking, service dependency ordering, and data volume management.

---

## Setting Up Docker Compose on Ubuntu

### Option 1: Install via Ubuntu Repository (Recommended)
This installs Docker along with the native `docker-compose-plugin`:
```bash
sudo apt update
sudo apt install docker-compose-v2 -y

```

### Option 2: Manual Installation (Specific Release)

To fetch a specific release binary manually:

```bash
sudo curl -SL [https://github.com/docker/compose/releases/download/v2.35.0/docker-compose-linux-x86_64](https://github.com/docker/compose/releases/download/v2.35.0/docker-compose-linux-x86_64) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

```

*Note: If installed via this method, use `docker-compose` instead of `docker compose`.*

---

## Example Deployment File

Save the following content as `compose.yaml` (the standard naming convention for modern Compose):

```yaml
services:
  nginx:
    image: nginx:latest
    ports:
      - "8081:80"
    restart: always # Ensures the container restarts automatically if it crashes or the daemon reboots

```

### Running the Compose File

1. **Start the services in the background (Detached Mode):**
```bash
docker compose up -d

```


*If using a custom filename (e.g., `nginx.yaml`):*
```bash
docker compose -f nginx.yaml up -d

```


2. **Verify running containers:**
```bash
docker compose ps

```


3. **Stop and remove containers (including networks):**
```bash
docker compose down

```



---

## Types of Volumes in Docker

Docker supports three main structural patterns for handling persistent or transient container data:

### 1. Named Volumes

* **Characteristics:** Fully managed by Docker. Isolated from direct host OS tampering. Ideal for production persistence and sharing data seamlessly between multiple containers.
* **Storage Location:** On Linux, Docker isolates these under `/var/lib/docker/volumes/`.

**CLI Operations:**

```bash
# List all managed volumes
docker volume ls

# Create a clean volume explicitly
docker volume create mydata

# Attach it to a container on the fly
docker run -d -v mydata:/data nginx

# Inspect details (e.g., to see its actual underlying mountpoint)
docker volume inspect mydata

```

**Interacting with Volume Data:**
You can quickly copy assets directly from your host machine into a directory tracked by a running container using `docker cp`:

```bash
docker cp /path/to/your/local/file container_name:/data/

```

**Compose Configuration:**

```yaml
services:
  nginx:
    image: nginx:latest
    volumes:
      - mydata:/usr/share/nginx/html

volumes:
  mydata:

```

---

### 2. Bind Mounts

* **Characteristics:** Maps a highly specific absolute or relative directory/file from the host filesystem directly into the container.
* **Best For:** High-speed local development workflows (e.g., hot-reloading source code or configuration changes).

**CLI Operations:**

```bash
docker run -d -v /absolute/path/on/host:/usr/share/nginx/html nginx

```

**Compose Configuration:**

```yaml
services:
  nginx:
    image: nginx:latest
    volumes:
      - ./html:/usr/share/nginx/html

```

---

### 3. tmpfs Mounts

* **Characteristics:** Stores data strictly inside host system memory (RAM). It never touches the host's physical persistent storage disk.
* **Best For:** Security-sensitive files (SSH keys, runtime tokens) or heavy, throwaway scratchpad data that requires high I/O throughput.

**CLI Operations:**

```bash
docker run -d --tmpfs /tmp nginx

```

**Compose Configuration (Long-Syntax Format):**

```yaml
services:
  nginx:
    image: nginx:latest
    volumes:
      - type: tmpfs
        target: /tmp

```

---

## Best Practices Summary

* Always append a `restart: always` or `restart: unless-stopped` policy to essential background services.
* Leverage **Bind Mounts** for dynamic local development, but stick to **Named Volumes** for high-performance production state preservation.
* Avoid treating the container filesystem as persistent; always isolate mutating state into separate networks and volume schemes.



