
# Installation Guide: Chocolatey and Docker Desktop

This guide outlines the steps to install the Chocolatey package manager and Docker Desktop on Windows.

## Prerequisites
* **OS:** Windows 10 or 11 (Pro, Enterprise, or Education recommended).
* **Permissions:** Administrator access is required.
* **Hardware:** Virtualization must be enabled in your BIOS/UEFI settings.

---

## 1. Install Chocolatey
Chocolatey is a command-line package manager that simplifies software management.

1. Right-click the **Start** button and select **Terminal (Admin)** or **Windows PowerShell (Admin)**.
2. Set the execution policy to allow the installation script:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   ```

3. Run the installation command:

    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    ```


4. Once finished, reload your environment variables:
    ```powershell
    refreshenv

    ```


5. **Verify:** Type `choco --version` to ensure it is installed correctly.

---

## 2. Install Docker Desktop

Using Chocolatey makes the Docker installation quick and handles the path configuration for you.

1. In the **Administrator PowerShell** window, run:
```powershell
choco install docker-desktop -y

```


2. **Restart your computer.** This is mandatory for the system to initialize the WSL 2 or Hyper-V containers feature.

---

## 3. Post-Installation & Verification

1. **Launch Docker:** Open "Docker Desktop" from the Start menu.
2. **Accept Terms:** Review and accept the Docker Subscription Service Agreement.
3. **Check Backend:** Ensure Docker is running. If prompted for a WSL 2 kernel update, download and install the package from the provided Microsoft link.
4. **Test Run:** Open a terminal and execute the following command:
```bash
docker run hello-world

```
If you see the "Hello from Docker!" message, your setup is complete.


