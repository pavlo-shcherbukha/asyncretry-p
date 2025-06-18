#!/bin/bash

echo "Create RabbitMQ Direct Exchange and Queues"

# RabbitMQ Test Credentials
export XUSR=<>
export XPSW=<>
export XHOST=localhost
export XPORT=15672
export XVHOST=%2F # Для віртуального хоста "/" потрібно використовувати %2F
export QUEUE_NAME=main-queue

echo "Read Message from RabbitMQ queue"
# Задайте назву черги, з якої потрібно читати повідомлення
export QUEUE_TO_READ=$QUEUE_NAME # Замініть на актуальну назву черги

# Параметри для запиту повідомлень
# count: кількість повідомлень для отримання
# ackmode: режим підтвердження
#   "ack_requeue_false": повідомлення буде видалено з черги після отримання (якщо підтверджено),
#                        або відправлено в dead-letter exchange / відкинуто, якщо не підтверджено.
#   "ack_requeue_true":  повідомлення повернеться в чергу, якщо не буде підтверджено.
# encoding: "auto" або "base64" (якщо "auto", RabbitMQ спробує визначити; якщо не вдасться, використає base64)
# truncate: максимальна довжина корисного навантаження повідомлення (payload), що повертається (в байтах)

PAYLOAD_DATA='{"count":1,"ackmode":"ack_requeue_false","encoding":"auto","truncate":50000}'

curl -u $XUSR:$XPSW \
     -X POST \
     -H "content-type:application/json" \
     -o "response.json" \
     -d "$PAYLOAD_DATA" \
     http://$XHOST:$XPORT/api/queues/$XVHOST/$QUEUE_TO_READ/get