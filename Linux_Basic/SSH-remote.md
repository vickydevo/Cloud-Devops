Connecting via SSH using a manually copied public key is a classic, foolproof method. It's the perfect workaround when `ssh-copy-id` isn't available or network restrictions get in the way.

Here is the step-by-step guide to get Instance A connected to Instance B.

---

### Step 1: Generate the SSH Key Pair on Instance A (Source)

First, log into **Instance A** and generate a new public/private key pair.

1. Run the keygen command:
```bash
ssh-keygen -t rsa -b 4096

```


*(Note: You can also use `-t ed25519` for a modern, shorter key).*
2. Press **Enter** to accept the default file location (`~/.ssh/id_rsa`).
3. (Optional) Enter a passphrase if you want extra security, or press **Enter** twice to leave it blank for passwordless automation.

### Step 2: Copy the Public Key

Still on **Instance A**, you need to view and copy the contents of your *public* key.

1. Display the public key:
```bash
cat ~/.ssh/id_rsa.pub

```


2. **Select and copy** the entire output string that appears on your terminal. It usually starts with `ssh-rsa` and ends with your username@hostname.

### Step 3: Add the Key to Instance B (Destination)

Now, log into **Instance B** (you can open a new terminal tab or use your existing password/method to get in).

1. Open (or create) the `authorized_keys` file using a text editor like `nano`:
```bash
nano ~/.ssh/authorized_keys

```


2. Move your cursor to a new line at the bottom of the file and **paste** the public key you copied from Instance A.
3. Save and exit the file (In `nano`, press `Ctrl + O`, then `Enter` to save, and `Ctrl + X` to exit).

### Step 4: Set the Correct Permissions on Instance B

SSH is incredibly strict about file permissions. If your directories are too open, SSH will reject the connection for security reasons.

Run these commands on **Instance B** to ensure everything is locked down properly:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

```

### Step 5: Test the Connection from Instance A

Go back to your terminal for **Instance A** and try to connect to Instance B:

```bash
ssh username@instance_b_ip

```

*(Replace `username` with the actual user on Instance B, and `instance_b_ip` with its actual IP address or hostname).*

If this is your first time connecting, your terminal will ask if you trust the host. Type **`yes`** and hit Enter. You should now be logged right into Instance B without being prompted for a password!