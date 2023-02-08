## PubNub Kafka Connector

This codebase includes a PubNub Sink Connector.
Kafka topic records can be coppied to a PubNub channel.
The Kafka topic name will match PubNub channel name.

### ✅ Requirements

* [Java 11+](https://openjdk.org/install)
* [Maven 3.8.6+](https://maven.apache.org/download.cgi)
* [Docker](https://www.docker.com/get-started)

## ⚙️  Building the connector

* Build the Kafka Connect connector file.

```bash
mvn clean package
```

💡 A file named `target/pubnub-kafka-connector-1.0.jar` will be created.

## ⬆️  Starting the local environment

With the connector properly built, you need to have a local environment to test it.
This project includes a Docker Compose file that can spin up container instances for Apache Kafka and Kafka Connect.
Additionally a sample producer feed starts on the `"pubnub"` topic.
This feed emits a sample message every few seconds.

Start the containers using Docker Compose.

```bash
docker compose up
```

Wait until the containers `kafka` and `connect` are started and healthy.

## ⏯ Deploying and the Sink Connector

This will copy data from the configured Kafka topic name to the PubNub channel with the same name.

* Deploy the connector.

```bash
curl -X POST -H "Content-Type:application/json" -d @examples/pubnub-sink-connector.json http://localhost:8083/connectors
```

## ⏹ Undeploy the connector

* Use the following command to undeploy the connector from Kafka Connect:

```bash
curl -X DELETE http://localhost:8083/connectors/pubnub-sink-connector
```

## ⬇️  Stopping the local environment

* Stop the containers using Docker Compose.

```bash
docker compose down
```
