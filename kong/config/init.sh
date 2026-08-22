#!/bin/sh

set -e

KONG_ADMIN="http://kong:8001"

echo "Waiting for Kong..."

until curl -sf "$KONG_ADMIN/status" >/dev/null; do
    sleep 2
done

echo "Kong is ready"

echo "Creating security service..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-security-v1" \
  --data name=hw-security-v1 \
  --data protocol=http \
  --data host=hw-security \
  --data port=3000 \
  --data path=/v1

echo "Creating token route..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-security-v1/routes/token" \
  --data name=token \
  --data paths[]=/token \
  --data methods[]=POST \
  --data strip_path=false

echo "Creating token validation route..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-security-v1/routes/token-validation" \
  --data name=token-validation \
  --data paths[]=/token/validation \
  --data methods[]=GET \
  --data strip_path=false

echo "Creating uploader service..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-uploader-v1" \
  --data name=hw-uploader-v1 \
  --data protocol=http \
  --data host=hw-uploader \
  --data port=3000 \
  --data path=/v1

echo "Creating upload route..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-uploader-v1/routes/upload" \
  --data name=upload \
  --data paths[]=/upload \
  --data methods[]=POST \
  --data strip_path=false

echo "Creating images route..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-uploader-v1/routes/images" \
  --data name=images \
  --data paths[]=/images \
  --data methods[]=GET \
  --data strip_path=false

echo "Creating storage-root..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-storage-root" \
  --data name=hw-storage-root \
  --data protocol=http \
  --data host=hw-storage \
  --data port=9000 \
  --data path=/minio/v2

echo "Creating storage-root route..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-storage-root/routes/hw-storage-metrics-cluster" \
  --data name=hw-storage-metrics-cluster \
  --data paths[]=/storage \
  --data methods[]=GET \
  --data strip_path=true

echo "Creating hw-security-root..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-security-root" \
  --data name=hw-security-root \
  --data protocol=http \
  --data host=hw-security \
  --data port=3000 \
  --data path=/

echo "Creating storage-root route..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-security-root/routes/hw-security-metrics" \
  --data name=hw-security-metrics \
  --data paths[]=/security \
  --data methods[]=GET \
  --data strip_path=true

echo "Creating hw-uploader-root..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-uploader-root" \
  --data name=hw-uploader-root \
  --data protocol=http \
  --data host=hw-uploader \
  --data port=3000 \
  --data path=/

echo "Creating hw-uploader-root route..."

curl -sf -X PUT "$KONG_ADMIN/services/hw-uploader-root/routes/hw-uploader-metrics" \
  --data name=hw-uploader-metrics \
  --data paths[]=/uploader \
  --data methods[]=GET \
  --data strip_path=true

echo "Creating Prometheus plugin..."

curl -sf -X PUT "$KONG_ADMIN/plugins/prometheus" \
  --data name=prometheus \
  --data config.status_code_metrics=true

echo "Kong configuration completed."


echo "Kong configuration completed."