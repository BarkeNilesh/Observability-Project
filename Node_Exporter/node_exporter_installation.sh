#!/bin/bash

set -e

NODE_EXPORTER_VERSION="1.11.1"

echo "Downloading Node Exporter..."

cd /tmp

wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "Extracting package..."

tar -xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "Creating node_exporter user..."

id node_exporter &>/dev/null || useradd --no-create-home --shell /bin/false node_exporter

echo "Installing binary..."

cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/

chown node_exporter:node_exporter /usr/local/bin/node_exporter

echo "Creating systemd service..."

cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."

systemctl daemon-reload

echo "Enabling and starting Node Exporter..."

systemctl enable node_exporter
systemctl restart node_exporter

echo "Checking service status..."

systemctl --no-pager status node_exporter

echo "Node Exporter installation completed."

echo "Verify metrics using:"
echo "curl http://localhost:9100/metrics"
