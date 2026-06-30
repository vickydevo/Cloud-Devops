#!/bin/bash
# Update package lists and automatically accept prompts
yes | sudo apt update

# Install Apache2 web server automatically
yes | sudo apt install apache2 -y

# Create custom index.html file featuring dynamic Hostname and IP Address variables
echo "<h1>Server Details</h1><p><strong>Hostname:</strong> $(hostname)</p><p><strong>IP Address:</strong> $(hostname -I | cut -d' ' -f1)</p>" > /var/www/html/index.html

# Restart Apache to apply any configurations
sudo systemctl restart apache2