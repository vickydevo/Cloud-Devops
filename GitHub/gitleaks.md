Here is your complete **Gitleaks Lab Setup** for both Windows and Linux, specifically tailored for your Java Spring Boot project.

---

## 1. Installation Guide

### Windows (Manual Setup)

Since you’ve already confirmed `gitleaks_8.29.1_windows_x64.zip` works:

1. **Download:** Get the `x64.zip` from the [official releases](https://github.com/gitleaks/gitleaks/releases).
2. **Extract:** Place `gitleaks.exe` in `C:\gitleaks\`.
3. **Path:** Add `C:\gitleaks` to your **System Environment Variables**.
4. **Bash Alias:** To use it in Git Bash without the full path, run:
```bash
echo "alias gitleaks='/c/gitleaks/gitleaks.exe'" >> ~/.bash_profile && source ~/.bash_profile

```



### Linux (Ubuntu/Debian)

Run these commands in your terminal:

```bash
# Download the Linux x64 version
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks_8.18.0_linux_x64.tar.gz

# Extract the binary
tar -xvzf gitleaks_8.18.0_linux_x64.tar.gz

# Move to your bin folder and make it executable
sudo mv gitleaks /usr/local/bin/
sudo chmod +x /usr/local/bin/gitleaks

# Verify
gitleaks version

```

---

## 2. Preparing the Java Spring Boot "Honey Pot"

To test the scanner, add these "secrets" to your project. **Warning:** Use fake keys like the ones below to avoid actual security risks during the lab.

### **In `src/main/resources/application.properties`:**

```properties
# Database credentials
spring.datasource.password=SuperSecretPassword123!
# Fake AWS Keys (Random enough to trigger entropy checks)
aws.access.key=AKIAY3Z0B1C2D3E4F5G6
aws.secret.key=v8N1S+pL9xR5qT2uW4yZ7A1B3C5D7E9F1G3H5I7J

```

### **In a Java Controller (`src/main/java/.../SecretController.java`):**

```java
@RestController
public class SecretController {
    // Hardcoded API Token
    private String githubToken = "ghp_nS1yOEcfP5pvfqJml36mF7AkyHsEU0IU36mF";
}

```

---

## 3. Running the Detection Scenarios

### Scenario A: Detecting "Uncommitted" Secrets (No-Git Mode)

Use this when you have typed code into your IDE but **haven't** run `git commit` yet.

```bash
gitleaks detect --source . --no-git --verbose

```

### Scenario B: Detecting "Committed" Secrets (History Mode)

Use this to scan your entire Git commit history. This is the default mode.

```bash
gitleaks detect --source . --verbose

```

### Scenario C: Saving Results to Standard Formats

Gitleaks supports **JSON**, **CSV**, and **SARIF** (used by GitHub Security).

```bash
# Save as JSON (best for machine reading)
gitleaks detect --source . --report-path=report.json --report-format=json

# Save as CSV (best for Excel/Human viewing)
gitleaks detect --source . --report-path=report.csv --report-format=csv

```

---

## 4. Automation: The Pre-Commit Hook

Prevent yourself from ever committing a secret again by setting up a hook in your project root:

1. Create/Edit `.git/hooks/pre-commit` (no extension).
2. Add this logic:
```bash
#!/bin/bash
gitleaks protect --staged --verbose
if [ $? -ne 0 ]; then
  echo "Error: Gitleaks detected secrets in your staged changes. Commit aborted."
  exit 1
fi

```


3. Make it executable (Linux/Git Bash): `chmod +x .git/hooks/pre-commit`

