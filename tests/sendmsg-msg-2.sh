#!/bin/bash

# --- Функції ---

# Функція для чистого виходу з циклу при натисканні Ctrl+C
function handle_exit() {
    echo -e "\n\nЗупинка скрипту..."
    exit 0
}

# Перехоплення сигналу SIGINT (Ctrl+C) для виклику функції handle_exit
trap handle_exit SIGINT

# --- Конфігурація ---

echo "Запуск періодичної відправки повідомлень в RabbitMQ Direct Exchange"
echo "Натисніть Ctrl+C, щоб зупинити."

# Інтервал між відправками повідомлень у секундах
INTERVAL_SECONDS=2

# --- Змінні середовища для підключення до RabbitMQ ---
export XUSR=<>
export XPSW=<>
export XHOST=localhost
export XPORT=15672
export XVHOST=%2F # Для віртуального хоста "/" потрібно використовувати URL-кодування %2F
export EXCHANGE_NAME=main-exchange
export ROUTING_KEY=srvc.transact.cash


# --- Головний цикл відправки повідомлень ---
# Скрипт буде працювати нескінченно, доки його не зупинять вручну (Ctrl+C)
while true; do
    echo "-----------------------------------------------------"
    echo "Відправка повідомлення... (Час: $(date +%T))"

    # --- Відправка повідомлення через RabbitMQ Management API ---
    curl -s -u "$XUSR:$XPSW" \
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
            "payload": "{\"num\": 1000, \"dbt\": \"1001001\", \"krd\": \"1007222\", \"amount\": 1.23, \"remark\": \"cash payment\"}",

       



            "payload_encoding": "string"
         }' > /dev/null # Перенаправляємо вивід curl, щоб не засмічувати консоль

    # Перевірка статусу виконання curl. $? містить код виходу попередньої команди.
    if [ $? -eq 0 ]; then
      echo "Повідомлення успішно відправлено."
    else
      echo "Помилка під час відправки повідомлення."
    fi

    # Пауза перед наступною відправкою
    echo "Наступна відправка через $INTERVAL_SECONDS секунд..."
    sleep $INTERVAL_SECONDS
done
