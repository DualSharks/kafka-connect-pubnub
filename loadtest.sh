#!/bin/bash

# Kafka Producer Performance Test
# Kafka Producer Performance Test Parameters
TOPIC="pubnub"
NUM_RECORDS=50
RECORD_SIZE=10
THROUGHPUT=5
BROKER_ADDRESS="PLAINTEXT://kafka:29092"

# Run the Kafka Producer Performance Test
docker exec -it producer kafka-producer-perf-test \
--topic $TOPIC \
--num-records $NUM_RECORDS \
--record-size $RECORD_SIZE \
--throughput $THROUGHPUT \
--producer-props bootstrap.servers=$BROKER_ADDRESS


# Wait for some time to collect metrics
sleep 300  # Adjust based on your test duration

# Prometheus Metrics Query
# Prometheus Query Parameters
PROMETHEUS_URL="http://localhost:9090" # Update with your Prometheus URL
QUERY="rate(kafka_connect_connector_status{status=\"RUNNING\"}[5m])" # Example metric

# Query Prometheus
curl -G -s "$PROMETHEUS_URL/api/v1/query" --data-urlencode "query=$QUERY" | jq '.data.result' > metrics.json

# Convert JSON to CSV (Example using jq)
jq -r '.[] | [.metric.__name__, .metric.instance, .value[1]] | @csv' metrics.json > metrics.csv

# Clean up
rm metrics.json

echo "Metrics exported to metrics.csv"
