Switch to root user 
--------------------
sudo -i or sudo su - 
## Working with Directories
----------------------------------

### **1. Viewing Manual Pages**
--------------------------------
- `man <command>` → Displays manual pages for a command.
- Example: `man pwd`

### **2. Navigating Directories**
-----------------------------------
- `pwd` → Print the current working directory.
- `cd <dir_name>` → Change directory.
- `cd .` → Stay in the current directory.
- `cd ..` → Move up one directory level.

### **3. Listing Directory Contents**
--------------------------------------
- `ls` → Lists files and directories.
- `ll` → Lists files in long format (if alias exists).
- `ls -a` → Lists all files, including hidden ones.
- `ls -al` → Lists all files with detailed information.
- `ls -lrat` → Lists files sorted by modification time in reverse order.

### **4. Creating and Removing Directories**
---------------------------------------------
- `mkdir <dir_name>` → Creates a new directory.
- `mkdir -p Linux/amazon/vignan` → Creates a nested directory structure.
- `rmdir <dir_name>` → Removes an empty directory.
- `rmdir -p Linux/amazon/vignan` → Removes nested directories if they are empty.
- `rmdir -vp Linux/amazon/vignan` → Verbosely removes nested empty directories.

---

## Working with Files
----------------------
-----------------------

### **1. Viewing File Types**
----------------------------------
- `man file` → Displays information about the `file` command.
- `file <filename>` → Identifies the file type.

### **2. Creating Files**
--------------------------
- `touch <filename>` → Creates an empty file.
- `echo 'string'` → Prints a string to the terminal.
- `echo 'string' > file1` → Creates `file1` with the specified string.

### **3. Copying Files**
---------------------------
- `cp file1.txt file1cp.txt` → Copies `file1.txt` to `file1cp.txt`.
- `cp file1.txt Linux/amazon/` → Copies `file1.txt` into `Linux/amazon/`.
- `cp file2.txt Linux/amazon/file2cpsp.txt` → Copies `file2.txt` and renames it.

### **4. Moving and Renaming Files**
--------------------------------------
- `mv file3 file3rename` → Renames `file3` to `file3rename`.
- `mv -vb file2 Linux/file2.py` → Moves `file2` to `Linux/` with verbose output and backup.

---

## Working with File Content
-------------------------------

### **1. Viewing File Content**
-----------------------------------
- `head -5 filename.txt` → Displays the first 5 lines.
- `tail -3 filename` → Displays the last 3 lines.
- `cat file1 file2 file3` → Concatenates and displays file contents.
- `cat > file1` → Creates a file and allows text input (press `Ctrl+C` to exit).

### **2. Copying File Content**
----------------------------------
- `cat file1 > file2` → Copies content of `file1` to `file2`.

### **3. Paginated File Viewing**
----------------------------------------
- `more file1` → Displays file content page by page.
- `less file1` → Similar to `more` but allows backward navigation.


## System Information Commands
-------------------------------

### **1. Viewing System Uptime and Load**
- `uptime` → Shows how long the system has been running, current time, number of users, and load averages.

### **2. Checking Memory Usage**
- `free` → Displays total, used, and free memory.
- `free -h` → Shows memory usage in a human-readable format.

### **3. Listing Running Processes**
- `ps` → Lists currently running processes for the current user.
- `ps -A` → Lists all running processes on the system.

### **4. Checking Disk Space**
- `df` → Displays disk space usage for all mounted filesystems.
- `df -h` → Shows disk space usage in human-readable format (e.g., MB, GB).

### **5. Viewing Disk Partitions**
- `fdisk -l` → Lists partition tables of all available disks (requires root privileges).

### **6. Displaying Block Devices**
- `lsblk` → Shows block devices (disks and partitions) in a tree-like format.

### **7. Monitoring System Performance**
- `top` → Displays real-time system performance, including CPU and memory usage.
- `htop` → Interactive process viewer with improved interface (may require installation).

---