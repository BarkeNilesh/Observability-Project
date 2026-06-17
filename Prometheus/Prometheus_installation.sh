#!/bin/bash

set -e

PROM_VERSION="3.5.0"

echo "Creating Prometheus user..."

if ! id prometheus >/dev/null 2>&1; then
	sudo useradd --no-create-home --shell /bin/false prometheus
fi

echo "Creating directories..."
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

echo "Downloading Prometheus..."
cd /tmp

rm -rf prometheus-${PROM_VERSION}.linux-amd64*

wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

echo "Extracting package..."
tar -xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

cd prometheus-${PROM_VERSION}.linux-amd64

echo "Installing binaries..."
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/

echo "Installing configuration..."
cp prometheus.yml /etc/prometheus/

echo "Setting permissions..."
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus

chmod -R 755 /usr/local/bin/prometheus
chmod -R 755 /usr/local/bin/promtool

echo "Creating systemd service..."

cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Monitoring Server
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple

ExecStart=/usr/local/bin/prometheus \
 --config.file=/etc/prometheus/prometheus.yml \
 --storage.tsdb.path=/var/lib/prometheus
 --storage.tsdb.retention.time=15d

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
systemctl daemon-reload

echo "Validating configuration..."
/usr/local/bin/promtool check config /etc/prometheus/prometheus.yml

echo "Enabling Prometheus..."
systemctl enable prometheus

echo "Starting Prometheus..."
systemctl restart prometheus

echo "Waiting for service startup..."
sleep 5

echo "Checking status..."
systemctl --no-pager --full status prometheus

echo
echo "Listening Port Check:"
ss -tulnp | grep 9090 || true

SERVER_IP=$(hostname -I | awk '{print $1}')

echo
echo "====================================================="
echo "Prometheus installation completed successfully."
echo "Access URL: http://${SERVER_IP}:9090"
echo "====================================================="
