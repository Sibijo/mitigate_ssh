#!/bin/bash

## Script to Mitigate OpenSSH Vulnerability by Adjusting LoginGraceTime
# Author: [Sibi Jose]
# Date: 11 July 2024

# Backup sshd_config with timestamp
backup_file="/etc/ssh/sshd_config_$(date +%Y%m%d%H%M%S).bak"
sudo cp /etc/ssh/sshd_config "$backup_file" && echo "Backup created: $backup_file"

# Check OpenSSH version and echo current version
if sshd -V 2>&1 | grep -q "OpenSSH"; then
    current_version=$(sshd -V 2>&1 | grep -oP 'OpenSSH_\K[0-9]+\.[0-9]+p[0-9]+')
    echo "Current OpenSSH version: $current_version"

    vulnerable_threshold="9.8p1"

    if [[ "$(echo "$current_version"; echo "$vulnerable_threshold") | sort -V | head -n1)" == "$vulnerable_threshold" ]]; then
        echo "OpenSSH version is vulnerable (below $vulnerable_threshold). Applying mitigation..."

        # Set LoginGraceTime to 0
        sudo sed -i '/^LoginGraceTime/d' /etc/ssh/sshd_config
        echo "LoginGraceTime 0" | sudo tee -a /etc/ssh/sshd_config

        # Restart SSHD service
        sudo systemctl restart sshd.service
        echo "Mitigation applied successfully."
    else
        echo "OpenSSH version is not vulnerable or already patched."
    fi
else
    echo "Error: OpenSSH not found or version information not available."
    exit 1
fi
