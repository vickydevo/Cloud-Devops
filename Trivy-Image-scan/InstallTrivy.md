
# Workshop: Docker Image Security Scanning with Trivy

This guide covers the installation, professional usage , and best practices for using Trivy to secure containerized applications.

---

## 1. Installation on Ubuntu
We use the official Aqua Security repository to ensure we have the latest features and vulnerability definitions.
Include this Offical documentation link :https://trivy.dev/docs/latest/getting-started/installation/

```bash
# 1.1 Install system dependencies
sudo apt-get install wget gnupg -y

# 1.2 Add the Aqua Security GPG Key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

# 1.3 Add the Trivy Repository
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# 1.4 Update package list and install
sudo apt-get update -y
sudo apt-get install trivy -y

# 1.5 Verify installation
trivy -v

```

---

## 2. Scanning Strategies (MNC Standards)

In professional environments (MNCs), scanning is focused on actionable results. We filter by **Severity** and use specific **Output Formats** for auditing.

### 2.1 The "Developer View" (Terminal Table)

Used for quick verification during development. The table format is the default.

```bash
# Scan everything
trivy image <YOUR_IMAGE_NAME>

# Filter by HIGH and CRITICAL vulnerabilities only
trivy image --severity HIGH,CRITICAL <YOUR_IMAGE_NAME>

```

### 2.2 The "Compliance View" (Report Generation)

MNCs export results into files to feed into security dashboards like DefectDojo or Splunk.

```bash
# Export as JSON for automated tools
trivy image --format json --output security-report.json <YOUR_IMAGE_NAME>

# Export as a readable text file for documentation
trivy image --severity HIGH,CRITICAL --format table --output report.txt springboot:v1

# View the generated report
cat report.txt

```

<img width="1208" height="571" alt="Image" src="https://github.com/user-attachments/assets/aed6ad65-32f7-4a7f-a88e-615a6ede537c" />

---
### 2.3 The "CI/CD Gate" (Enforcing Security)

To prevent insecure images from reaching production, we configure Trivy to "break the build" in Jenkins if a vulnerability is found.

```bash
# --exit-code 1 returns a failure status to Jenkins if CRITICAL issues exist
trivy image --exit-code 1 --severity CRITICAL <YOUR_IMAGE_NAME>

```

---

## 3. Advanced Features & Best Practices

### 3.1 Ignore Unfixed Vulnerabilities

Some vulnerabilities are known but do not have a patch available yet. To focus only on issues you can actually fix:

```bash
trivy image --ignore-unfixed <YOUR_IMAGE_NAME>

```

### 3.2 Scanning the Filesystem (Source Code)

Trivy can scan your project directory before you even build your Docker image. This is useful for finding vulnerable libraries in `pom.xml` or hardcoded secrets.

```bash
# Scan the current directory
trivy fs .

```
 find / -name "html.tpl" 2>/dev/null
include above and explain why it need
### 3.3 Clear Cache (Storage Management)

If you run out of disk space or need to force a database update:

```bash
trivy image --reset

```

---

## 4. Summary Table of Flags

| Flag | Description |
| --- | --- |
| `--severity` | Filter results (LOW, MEDIUM, HIGH, CRITICAL) |
| `--format` | Output style (table, json, template) |
| `--output` | Save results to a specific file |
| `--exit-code` | Return 1 on failure (useful for CI/CD) |
| `--ignore-unfixed` | Hide vulnerabilities that don't have a patch yet |

---



