#!/bin/bash

# Wait for cloud-init & dpkg lock issues
sleep 30

sudo apt update --fix-missing -y

# Retry installation until it succeeds
until sudo apt install -y nginx; do
    echo "Retrying nginx installation..."
    sleep 5
done

sudo systemctl enable nginx
sudo systemctl start nginx

echo "<h1>Nginx installed and started successfully on Ubuntu 24.04. <br> Private IP: $(hostname -I | awk '{print $1}')</h1>" > /var/www/html/index.html
sudo systemctl restart nginx