#!/bin/bash

set -e

PROM_VERSION="3.5.0"

echo "Creating Prometheus user..."
id prometheus &>/dev/null || useradd --no-create-home --shell /bin/false prometheus

echo "Creating directories..."
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

echo "Downloading Prometheus..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

echo "Extracting package..."
tar -xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROM_VERSION}.linux-amd64

echo "Installing binaries..."
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/

echo "Installing configuration..."
cp prometheus.yml /etc/prometheus/
#cp -r consoles /etc/prometheus/
#cp -r console_libraries /etc/prometheus/

echo "Setting permissions..."
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus

echo "Creating systemd service..."

cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring Server
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple

ExecStart=/usr/local/bin/prometheus \
 --config.file=/etc/prometheus/prometheus.yml \
 --storage.tsdb.path=/var/lib/prometheus \
# --web.console.templates=/etc/prometheus/consoles \
# --web.console.libraries=/etc/prometheus/console_libraries

Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
systemctl daemon-reload

echo "Enabling Prometheus..."
systemctl enable prometheus

echo "Starting Prometheus..."
systemctl start prometheus

echo "Checking status..."
systemctl status prometheus --no-pager

echo ""
echo "Prometheus installation completed."
echo "Access URL: http://$(hostname -I | awk '{print $1}'):9090"
