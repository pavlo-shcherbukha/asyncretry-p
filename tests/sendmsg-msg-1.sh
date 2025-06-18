#!/bin/bash

# Функція для паузи, щоб можна було побачити результат виконання
function pause(){
   read -p "$*"
}

echo "Відправка повідомлення в RabbitMQ Direct Exchange"

# --- Змінні середовища для підключення до RabbitMQ ---
# Краще виносити конфігурацію в змінні для гнучкості
export XUSR=<>
export XPSW=<>
export XHOST=localhost
export XPORT=15672
# Для віртуального хоста "/" потрібно використовувати URL-кодування %2F
export XVHOST=%2F
export EXCHANGE_NAME=main-exchange
export ROUTING_KEY=srvc.transact.cash

# --- Відправка повідомлення через RabbitMQ Management API ---
# Пояснення виправлень:
# 1. Додано зворотні слеші (\) в кінці кожного рядка команди curl.
#    Це необхідно, щоб bash розумів, що команда продовжується на наступному рядку.
# 2. Поле "payload" має бути рядком (оскільки "payload_encoding": "string").
#    Тому внутрішній JSON-об'єкт було перетворено на рядок з екранованими лапками.
# 3. Для чистоти коду URL та метод (-X POST) перенесено вище.
curl -u "$XUSR:$XPSW" \
     -H "Content-Type: application/json" \
     -X POST "http://$XHOST:$XPORT/api/exchanges/$XVHOST/$EXCHANGE_NAME/publish" \
     -d '{
        "properties": {
            "persistent": true,
            "correlation_id": "1234567890",
            "reply_to": "reply-queue",
            "content_type": "application/json",
            "headers": {
                "x-request-type": "SendNormalTransaction",
                "x-unit-test": "consumeTransaction"
            }
        },
        "routing_key": "'"$ROUTING_KEY"'",
        "payload": "{\"num\": 1000, \"dbt\": \"1001001\", \"krd\": \"1007222\", \"amount\": 1000.23, \"remark\": \"cash payment\"}",
        "payload_encoding": "string"
     }'

# Перевірка статусу виконання curl. $? містить код виходу попередньої команди.
if [ $? -eq 0 ]; then
  echo -e "\n\nПовідомлення успішно відправлено."
else
  echo -e "\n\nПомилка під час відправки повідомлення."
fi


echo -e "\nНатисніть будь-яку клавішу для виходу..."
pause
