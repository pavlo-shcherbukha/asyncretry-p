#!/bin/bash


function pause(){
   read -p "$*"
}

echo "Create RabbitMQ Direct Exchange and Queues"

# RabbitMQ Test Credentials
export XUSR=<>
export XPSW=<>
export XHOST=localhost
export XPORT=15672
export XVHOST=%2F # Для віртуального хоста "/" потрібно використовувати %2F
export QUEUE_NAME1=reply-queue
export QUEUE_NAME2=main-queue
export QUEUE_NAME3=retry-queue
export QUEUE_NAME4=parking-queue

export EXCHANGE_NAME1=retry-exchange
export EXCHANGE_NAME2=main-exchange



echo "Delete RabbitMQ exchange"
curl -u $XUSR:$XPSW -X DELETE \
http://$XHOST:$XPORT/api/exchanges/$XVHOST/$EXCHANGE_NAME1

curl -u $XUSR:$XPSW -X DELETE \
http://$XHOST:$XPORT/api/exchanges/$XVHOST/$EXCHANGE_NAME2




echo "Delete RabbitMQ queue"
curl -u $XUSR:$XPSW -X DELETE \
http://$XHOST:$XPORT/api/queues/$XVHOST/$QUEUE_NAME1

curl -u $XUSR:$XPSW -X DELETE \
http://$XHOST:$XPORT/api/queues/$XVHOST/$QUEUE_NAME2


curl -u $XUSR:$XPSW -X DELETE \
http://$XHOST:$XPORT/api/queues/$XVHOST/$QUEUE_NAME3

curl -u $XUSR:$XPSW -X DELETE \
http://$XHOST:$XPORT/api/queues/$XVHOST/$QUEUE_NAME4


echo "press any key to continue"
pause
