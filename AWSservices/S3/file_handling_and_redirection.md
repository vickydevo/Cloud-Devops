# **File Concatenation and Output Redirection in Linux**

## **File Concatenation**
### **Merging Multiple Files**
To merge multiple files into one:
```sh
cat file1 file2 file3 > merged.txt
```
This combines `file1`, `file2`, and `file3` into `merged.txt`, overwriting any existing content.

### **Appending Content to a File**
To create and input content interactively:
```sh
cat > newfile.txt
```
Type content and press `Ctrl + D` to save and exit.

To append predefined content:
```sh
cat >> filename.txt <<EOF
--------------------------
Additional Information
More text
--------------------------
EOF
```
This appends the enclosed text to `filename.txt`.

---

## **Output Redirection in Linux**

### **Difference Between `printf` and `echo`**
| Feature        | `printf`                                 | `echo`                                 |
|---------------|----------------------------------------|--------------------------------------|
| **Formatting** | Supports format specifiers (`%s`, `\n`) | Requires `-e` to enable escape sequences |
| **Portability** | Consistent across shells              | Behavior varies by shell              |
| **Use Case**   | Structured output                      | Simple text output                     |

### **Example Usage**
```sh
printf "Welcome to Training\n1. DevOps\n2. Security\n3. Web Development\n" > training.txt

echo -e "Welcome to Training\n1. DevOps\n2. Security\n3. Web Development" >> training.txt
```

#### **Understanding `-e` in `echo`**
The `-e` option enables interpretation of escape sequences like `\n` (newline) and `\t` (tab). Without `-e`, these characters would be printed literally.

---

## **Installing Java on Amazon Linux**
```sh
sudo yum install java
```
To store the Java version output:
```sh
java --version > version.txt
```
This saves the output to `version.txt`.

---

## **File Descriptors and Redirection**
Linux assigns numbers to standard input, output, and error streams:
| Descriptor | Purpose                    |
|------------|----------------------------|
| `0`        | Standard Input (STDIN)     |
| `1`        | Standard Output (STDOUT)   |
| `2`        | Standard Error (STDERR)    |

### **Using STDIN (File Descriptor `0`)**
Redirecting input to a command:
```sh
cat < inputfile.txt
```

```sh
read name <<< "John Doe"
echo "Name entered: $name"
```
This assigns "John Doe" to `name` without manual input.
### **Redirecting STDOUT and STDERR Separately**
```sh
ls > output.txt  # Saves standard output
java -vers 2> error.txt  # Saves error messages
```

### **Storing Both Success and Error Messages Separately**
```sh
java --version 1>success.txt 2>error.txt
```
Saves standard output to `success.txt` and errors to `error.txt`.

### **Merging STDOUT and STDERR**
```sh
java --version > combined_output.txt 2>&1
```
OR
```sh
java --version &> combined_output.txt
```
Both commands merge output and errors into `combined_output.txt`.

### **Suppressing Output**
To discard both STDOUT and STDERR:
```sh
systemctl status docker &> /dev/null
```
This prevents the command from displaying any output.

---

# System Information Logging Script

## Task: Log System Information and Errors

### Description
This script collects essential system details and logs them for monitoring purposes. It performs the following tasks:

- Retrieves the **current date and time**.
- Captures **system uptime**.
- Logs **disk usage statistics**.
- Records **memory usage details**.
- Redirects standard output (system information) to a file named **`system_info.log`**.
- Captures any errors separately in **`error.log`**.

### Usage
1. Ensure you have execution permissions for the script:
   ```sh
   chmod +x script_system_info.sh

## Expected Output
```sh
Date: Wed Mar 13 12:00:00 UTC 2025
Uptime: 5 days, 3:45

Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1      50G   20G   30G  40% /

Memory Usage:
             total        used        free      shared  buff/cache   available
Mem:        8192MB      4096MB      2048MB       512MB      1536MB      5120MB
```
