#!/bin/bash


function pause(){
   read -p "$*"
}

echo "Create RabbitMQ Retry queue configuration"

# RabbitMQ Test Credentials
export XUSR=<>
export XPSW=<>
export XHOST=localhost
export XPORT=15672


echo "Creating RabbitMQ retry-queue"


curl -u $XUSR:$XPSW -X PUT \
-H "Content-Type: application/json" \
-d '{"auto_delete":false,"durable":true,"arguments":{ "x-message-ttl": 30000, "x-dead-letter-exchange": "main-exchange" }}' \
http://$XHOST:$XPORT/api/queues/%2F/retry-queue



echo "Creating RabbitMQ main-queue"
curl -u $XUSR:$XPSW -X PUT \
-H "Content-Type: application/json" \
-d '{"auto_delete":false,"durable":true,"arguments":{"x-dead-letter-exchange": "retry-exchange"}}' \
http://$XHOST:$XPORT/api/queues/%2F/main-queue


echo "Creating RabbitMQ reply-queue"

curl -u $XUSR:$XPSW -X PUT \
-H "Content-Type: application/json" \
-d '{"auto_delete":false,"durable":true,"arguments":{}}' \
http://$XHOST:$XPORT/api/queues/%2F/reply-queue


echo "Creating RabbitMQ parking queue"

curl -u $XUSR:$XPSW -X PUT \
-H "Content-Type: application/json" \
-d '{"auto_delete":false,"durable":true,"arguments":{}}' \
http://$XHOST:$XPORT/api/queues/%2F/parking-queue




echo "Creating RabbitMQ retry-exchange"
curl -u $XUSR:$XPSW -X PUT \
-H "Content-Type: application/json" \
-d '{"type":"fanout","durable":true,"auto_delete":false,"internal":false,"arguments":{}}' \
http://$XHOST:$XPORT/api/exchanges/%2F/retry-exchange


echo "Creating RabbitMQ main-exchange"
curl -u $XUSR:$XPSW -X PUT \
-H "Content-Type: application/json" \
-d '{"type":"direct","durable":true,"auto_delete":false,"internal":false,"arguments":{}}' \
http://$XHOST:$XPORT/api/exchanges/%2F/main-exchange




echo "Bind queue to exchange main"
curl -u $XUSR:$XPSW -X POST \
-H "Content-Type: application/json" \
-d '{"routing_key":"srvc.transact.cash","arguments":{}}' \
http://$XHOST:$XPORT/api/bindings/%2F/e/main-exchange/q/main-queue


echo "baind retry q of exhcange retry"
curl -u $XUSR:$XPSW -X POST \
-H "Content-Type: application/json" \
-d '{"routing_key":"","arguments":{}}' \
http://$XHOST:$XPORT/api/bindings/%2F/e/retry-exchange/q/retry-queue




echo "press any key to continue"
pause