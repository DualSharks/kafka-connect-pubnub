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

# Initialize CSV file with headers
echo "Timestamp,Error Rate,Throughput Rate,Speed" > $CSV_FILE

# Produce messages and collect metrics
for ((i=1; i<=NUM_RECORDS; i++)); do
    # Generate a message with the current timestamp
    TIMESTAMP=$(date +%s)
    MESSAGE="{\"timestamp\":\"$TIMESTAMP\"}"

    # Produce the message to Kafka
    echo "$MESSAGE" | docker exec -i consumer kafka-console-producer --broker-list $BROKER_ADDRESS --topic $TOPIC

    # Sleep to control the throughput
    sleep $((1/THROUGHPUT))

    # Query Prometheus for metrics
    ERROR_RATE=$(query_prometheus "rate(kafka_connect_sink_task_metrics_sink_record_write_total{connector=\"$CONNECTOR_NAME\"}[1m])")
    THROUGHPUT_RATE=$(query_prometheus "rate(kafka_connect_sink_task_metrics_sink_record_write_total{connector=\"$CONNECTOR_NAME\"}[1m])")
    SPEED=$(query_prometheus "rate(kafka_connect_sink_task_metrics_put_batch_avg_time_ms{connector=\"$CONNECTOR_NAME\"}[1m])")

    # Append metrics to CSV file
    echo "$TIMESTAMP,$ERROR_RATE,$THROUGHPUT_RATE,$SPEED" >> $CSV_FILE
done

echo "Load test completed. Results saved to $CSV_FILE"
