
## 1. Install Docker (Official Repository)

For Ubuntu 24.04, it is best practice to use the official Docker repository rather than the default `apt` version to ensure you have the latest stable release.

### 1.1 Install Dependencies & Add GPG Key
First, update your package index and install the necessary certificates. Then, securely add Docker's official GPG key to verify package integrity.

```bash
sudo apt update
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

```

### 1.2 Add Docker Repository

Create the repository source file to allow `apt` to pull Docker packages directly from the official servers.

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu)
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

```

### 1.3 Install Docker Engine

Update the package index again to include the new repository and install the Docker Engine components.

```bash
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

```

---

## 2. Configure Docker Permissions

By default, Docker requires root privileges. To run Docker commands without using `sudo` (which is essential for CI/CD pipelines and developer productivity), follow these steps to add your user to the Docker group.

### 2.1 Create Group and Add User

```bash
# Create the docker group (usually created automatically during installation)
sudo groupadd docker

# Add your current user to the docker group
sudo usermod -aG docker $USER

```

### 2.2 Apply Group Changes

To apply the changes to your current session without logging out and back in, use the `newgrp` command.

```bash
newgrp docker

```

---

## 3. Verification

Verify that the installation was successful and that permissions are correctly configured by running the "Hello World" container.

```bash
docker run hello-world

```

If successful, Docker will pull the test image, run it, and print a confirmation message.

```

