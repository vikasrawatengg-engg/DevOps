#!/bin/bash
# 1. Update the local package manager registry
sudo apt-get update -y

# 2. Install the Apache2 Web Server package
sudo apt-get install apache2 -y

# 3. Start and enable the web service daemon
sudo systemctl start apache2
sudo systemctl enable apache2

# 4. Create a custom test splash page
echo "<h1>Welcome to Apache automated via Terraform!</h1>" | sudo tee /var/www/html/index.html