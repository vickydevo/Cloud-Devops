
# Enabling Hardware Virtualization for Docker Desktop

To run **Docker Desktop** on Windows, hardware virtualization must be enabled in your system's BIOS or UEFI. Without this setting, Docker cannot initialize the Linux kernel required to run containers.

---

## Why is Virtualization Required?

Docker containers are natively built for Linux. To bridge the gap and run them on Windows, Docker utilizes a "guest" Linux kernel through **WSL 2 (Windows Subsystem for Linux)** or **Hyper-V**. These technologies rely on the following:

* **Isolation:** Virtualization allows the CPU to carve out a secure, isolated environment for the Linux kernel to operate without interfering with your Windows OS.
* **Performance:** Hardware-assisted virtualization (**Intel VT-x** or **AMD-V**) is significantly faster and more efficient than older software-based emulation methods.
* **WSL 2 Backend:** Modern Docker installations use WSL 2, which acts as a lightweight utility virtual machine that requires hardware-level access.

---

## How to Check Your Current Status

Before restarting your computer, check if virtualization is already active via the Windows Task Manager:

1. Press `Ctrl` + `Shift` + `Esc` to open **Task Manager**.
2. Navigate to the **Performance** tab and select **CPU**.
3. Look at the bottom-right section under the graph.
4. Locate **Virtualization**:

<img width="1500" height="890" alt="Image" src="https://github.com/user-attachments/assets/0c27ef21-e925-4949-acaf-dff598fd03f3" />

* **Enabled:** You are ready to install/run Docker.
* **Disabled:** You must enable it in the BIOS/UEFI.



---

## How to Enable Virtualization in BIOS/UEFI

Because every motherboard manufacturer uses a different interface, the exact steps may vary. However, the general process is as follows:

### 1. Enter the BIOS/UEFI

Restart your computer. While it is booting up, repeatedly tap the BIOS key. Common keys include:

* **F2** or **Del** (Most desktops and laptops)
* **F10** (HP laptops)
* **F12** (Dell or Lenovo)

### 2. Locate the Virtualization Setting

Once inside the BIOS, look for tabs named **Advanced**, **CPU Configuration**, or **Security**.

### 3. Enable the Feature

The setting name depends on your processor type:

* **For Intel CPUs:** Look for *Intel Virtualization Technology* or *VT-x*.

![Image](https://github.com/user-attachments/assets/3fcd9313-1b42-460b-9c49-3293f45f00bf)

* **For AMD CPUs:** Look for *SVM Mode* or *Secure Virtual Machine*.

### 4. Save and Exit

Switch the setting to **Enabled**. Press the key for **Save and Exit** (usually **F10**) to restart your computer and apply the changes.

---

> **Note:** If you are using a corporate laptop and cannot access the BIOS, you may need to contact your IT administrator to enable these features.
