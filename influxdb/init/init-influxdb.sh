#!/bin/bash
# InfluxDB2の初期化スクリプト
# InfluxDB2のバケットを作成する
# 環境変数
# - INFLUXDB_URL: InfluxDBのURL
# - INFLUXDB_TOKEN: InfluxDBのトークン
# - INFLUXDB_ORG: InfluxDBの組織名
# - INFLUXDB_BUCKETS: InfluxDBのバケット名（カンマ区切り）

# InfluxDBが起動するのを待つ
echo "Waiting for InfluxDB to be ready..."
while ! curl --output /dev/null --silent --head --fail "$INFLUXDB_URL/health"; do
  printf '.'
  sleep 5
done

# 組織IDの取得
org_id=$(curl -s -X GET "$INFLUXDB_URL/api/v2/orgs" \
  -H "Authorization: Token $INFLUXDB_TOKEN" | jq -r '.orgs[] | select(.name=="'"$INFLUXDB_ORG"'") | .id')

# バケット作成
BUCKETS=(${INFLUXDB_BUCKETS//,/ })
for bucket in "${BUCKETS[@]}"; do
  echo "Creating bucket: $bucket"
  curl -XPOST "$INFLUXDB_URL/api/v2/buckets" \
    -H "Authorization: Token $INFLUXDB_TOKEN" \
    -H "Content-type: application/json" \
    -d '{
          "orgID": "'$org_id'",
          "name": "'$bucket'",
          "retentionRules": [{"type": "expire", "everySeconds": 31536000}]
        }'
done
