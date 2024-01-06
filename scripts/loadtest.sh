#!/bin/bash

# Kafka-related variables
TOPIC="pubnub"
BROKER_ADDRESS="PLAINTEXT://kafka:29092"
NUM_RECORDS=500
THROUGHPUT=5  # Messages per second

# Prometheus-related variables
PROMETHEUS_URL="http://localhost:9090" # Update with your Prometheus URL
CONNECTOR_NAME="pubnub-sink-connector"
CSV_FILE="load_test_results.csv"

# Function to query Prometheus
query_prometheus() {
    local query=$1
    local result=$(curl -G -s "$PROMETHEUS_URL/api/v1/query" --data-urlencode "query=$query" | jq -r '.data.result[0].value[1]')
    echo $result
}

# Produce messages and collect metrics
for ((i=1; i<=NUM_RECORDS; i++)); do
    # Generate a message with the current timestamp
    TIMESTAMP=$(date +%s)
    MESSAGE="{\"timestamp\":\"$TIMESTAMP\"}"

    # Produce the message to Kafka
    echo "$MESSAGE" | docker exec -i consumer kafka-console-producer --broker-list $BROKER_ADDRESS --topic $TOPIC

    # Sleep to control the throughput
    sleep $((1/THROUGHPUT))
done
