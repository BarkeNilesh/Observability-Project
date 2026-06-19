#!/bin/bash

set -e

echo "Installing Grafana..."

# Import Grafana GPG key
rpm --import https://rpm.grafana.com/gpg.key

# Configure Grafana repository
cat > /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=Grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# Install Grafana
yum install -y grafana

# Enable and start service
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

echo "Checking Grafana status..."
systemctl status grafana-server --no-pager

echo ""
echo "Checking listening port..."
ss -tulnp | grep 3000 || true

SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=========================================="
echo "Grafana installation completed"
echo "URL: http://${SERVER_IP}:3000"
echo "Default Username: admin"
echo "Default Password: admin"
echo "=========================================="
