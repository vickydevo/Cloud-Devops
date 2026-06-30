Setting up Nginx as a reverse proxy, managing its logs, and keeping those logs from taking over your hard drive is a foundational DevOps workflow.

Here is a complete, step-by-step breakdown of how to install it, configure it, find all your critical files, and set up automatic log rotation.

---

## 1. Installation & Key Locations

First, install Nginx on your Linux instance (assuming Ubuntu/Debian here):

```bash
sudo apt update
sudo apt install nginx -y

```

### The Locations You Asked For:

* **Default `index.html` Location:** `/var/www/html/index.html`
*(This is the default file Nginx serves if you visit the server's IP directly before configuring a proxy).*
* **Nginx Logs Directory:** `/var/log/nginx/`
* **Access Log:** `/var/log/nginx/access.log` (Tracks every request hitting your server).
* **Error Log:** `/var/log/nginx/error.log` (Tracks configuration issues, crashes, or 4xx/5xx routing errors).


* **Main Configuration Directory:** `/etc/nginx/`

---

## 2. Configuring Nginx as a Reverse Proxy

A reverse proxy sits in front of your application server (like a Node.js, Python, or Java app running on an internal port) and forwards client requests to it.

Let's say your actual application is running locally on port `3000` (`http://127.0.0.1:3000`). You want Nginx to listen on standard HTTP port `80` and route traffic to it.

1. Create a new configuration file for your site:
```bash
sudo nano /etc/nginx/sites-available/myapp

```


2. Paste the following configuration block:
```nginx
server {
    listen 80;
    server_name your_domain_or_ip;

    # Main reverse proxy logic
    location / {
        proxy_pass http://127.0.0.1:3000; 
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Custom log locations for this specific app (Optional but recommended)
    access_log /var/log/nginx/myapp_access.log;
    error_log /var/log/nginx/myapp_error.log;
}

```


3. Enable the configuration by linking it to the `sites-enabled` directory:
```bash
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/

```


4. Test the Nginx syntax for errors:
```bash
sudo nginx -t

```


5. If it says "syntax is ok", restart Nginx to apply changes:
```bash
sudo systemctl restart nginx

```



---

## 3. Understanding Nginx Logs

When you look at `/var/log/nginx/access.log` (using a command like `tail -f /var/log/nginx/access.log`), a typical log entry looks like this:

> `192.168.1.50 - - [29/Jun/2026:22:23:00 +0000] "GET /index.html HTTP/1.1" 200 612 "-" "Mozilla/5.0..."`

### Breaking Down the Log:

* **`192.168.1.50`**: The IP address of the client making the request.
* **`[29/Jun/2026...]`**: The exact timestamp of the request.
* **`"GET /index.html HTTP/1.1"`**: The HTTP method, the requested path, and the protocol version.
* **`200`**: The HTTP status code (200 means Success, 404 means Not Found, 502 means Bad Gateway/Proxy error).
* **`612`**: The size of the response sent to the client in bytes.

---

## 4. Managing Log Bloat using Logrotate

On a busy server, logs can grow to gigabytes in size very quickly, filling up your disk space ("log bloat"). **`logrotate`** is a built-in Linux utility that automatically backs up, compresses, and clears out old log files daily or weekly.

Nginx automatically comes with a pre-configured `logrotate` script when you install it.

### How to Inspect or Edit the Logrotate Rule:

Open the Nginx logrotate configuration file:

```bash
sudo nano /etc/logrotate.d/nginx

```

Inside, you will see a configuration that looks similar to this:

```text
/var/log/nginx/*.log {
        daily            # Rotate logs every single day
        missingok        # If a log file is missing, don't throw an error
        rotate 14        # Keep 14 days worth of logs, delete older ones
        compress         # Gzip (.gz) old logs to save massive disk space
        delaycompress    # Wait until the next rotation cycle to compress
        notifempty       # Do not rotate the log if it is empty
        create 0640 nginx adm  # Create new empty log files with these permissions
        sharedscripts
        postrotate
                if [ -f /var/run/nginx.pid ]; then
                        kill -USR1 `cat /var/run/nginx.pid`
                fi
        endscript
}

```

### Key Settings to Prevent Bloat:

* **`daily` / `weekly**`: Defines how often the logs cycle. Changing this to `daily` prevents any single log file from getting too huge.
* **`rotate 14`**: This ensures you only ever keep 14 log files on your system. If day 15 hits, the oldest file is deleted. You can reduce this to `7` or `5` if you are severely limited on disk space.
* **`compress`**: This is your best weapon against bloat. Text files compress incredibly well; a 100MB log file often shrinks down to just 2-3MB.