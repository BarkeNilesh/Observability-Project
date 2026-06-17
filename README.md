# Observability-Project
This project demonstrates the installation, configuration, and integration of Prometheus and Grafana for monitoring and observability. It covers setting up Prometheus for metrics collection and Grafana for visualization, enabling real-time monitoring of system and application performance through customizable dashboards and alerts.

###########################################################################################################
Step 1: Check Prometheus is Running
Check service on server: systemctl status prometheus
Check: curl http://localhost:9090/-/healthy
Output: Prometheus is Healthy.
Open in browser (Chrome/Edge): http://<SERVER-PUBLIC-IP>:9090 

Step 2: Log in to Grafana
Open in browser (Chrome/Edge): http://<SERVER-PUBLIC-IP>:3000
Default credentials:   Username: admin
                       Password: admin

Step 3: Add Prometheus as a Data Source
In Grafana -> Connections -> Add data source -> Select Prometheus -> For URL enter: http://<PROMETHEUS-PUBLIC-IP>:9090 -> Save & Test
Expected: Successfully queried the Prometheus API

Step 4: Import a Dashboard







