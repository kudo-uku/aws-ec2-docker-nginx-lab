#!/bin/bash

echo "=== AWS EC2 Docker Nginx Health Check ==="
echo

echo "[1] Current directory"
pwd
echo

echo "[2] Docker Compose service status"
sudo docker compose ps
echo

echo "[3] Local HTTP check: http://127.0.0.1"
if curl -s -f http://127.0.0.1 > /tmp/day69-local-check.html; then
  echo "OK: Local Nginx response received."
else
  echo "FAIL: Local Nginx response failed."
fi
echo

echo "[4] Port 80 listening check"
if sudo ss -tulpn | grep ':80'; then
  echo "OK: Port 80 is listening on EC2."
else
  echo "FAIL: Port 80 is not listening."
fi
echo

echo "[5] EC2 metadata check"
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/dynamic/instance-identity/document | grep -E '"region"|"availabilityZone"|"instanceId"'
echo

echo "[6] Nginx logs"
sudo docker compose logs --tail 7 web
echo

echo "=== Health check finished ==="
