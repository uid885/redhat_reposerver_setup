#!/bin/bash
# Author                 : Christo Deale
# Date	                 : 2024-04-16
# redhat_reposerver_setup: Utility to setup & configure repository server

# Prompt for input
read -p "Enter the username for repository ownership (default: ssadmin): " USERNAME
USERNAME=${USERNAME:-ssadmin}

read -p "Enter the name of the repository directory (default: repo-packages-homelab): " REPO_DIR
REPO_DIR=${REPO_DIR:-repo-packages-homelab}

read -p "Enter the name of the Apache document root directory (default: redhat_repo): " DOC_ROOT
DOC_ROOT=${DOC_ROOT:-redhat_repo}

# Update the system
sudo dnf update -y

# Install required packages
sudo dnf install -y createrepo yum-utils httpd

# Create repository directory
sudo mkdir -p /opt/"$REPO_DIR"

# Set ownership of repository directory
sudo chown -R "$USERNAME:$USERNAME" /opt/"$REPO_DIR"

# Sync repository data
sudo reposync --gpgcheck --repoid=rhel-9-for-x86_64-baseos-rpms -p /opt/"$REPO_DIR"/

# Create repository metadata
sudo createrepo /opt/"$REPO_DIR"

# Enable and start Apache HTTP server
sudo systemctl enable httpd
sudo systemctl start httpd

# Create directory for Apache document root
sudo mkdir -p /var/www/html/"$DOC_ROOT"

# Set ownership and permissions for Apache document root
sudo chown -R apache:apache /var/www/html/"$DOC_ROOT"
sudo chmod -R 755 /var/www/html/"$DOC_ROOT"

# Copy repository data to Apache document root
sudo cp -r /opt/"$REPO_DIR"/* /var/www/html/"$DOC_ROOT"/

# Display the content of the repository directory
ls -l /var/www/html/"$DOC_ROOT"

# Display the status of Apache HTTP server
sudo systemctl status httpd

# Disable SELinux (optional, for testing purposes)
sudo setenforce 0

# Allow HTTPS traffic through the firewall
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "Repository server setup completed successfully."
echo "You can access the repository at https://192.168.0.13/$DOC_ROOT"

