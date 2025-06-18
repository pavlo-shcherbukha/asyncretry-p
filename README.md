# Project asyncretry Prototype queue retry pattern with Node.js and Rabbit MQ

## In this repo

- Simple  Node.js publisher for RabbitMQ
- Simple Node.js consumer
- Example how to user ReplyTo pattern
- Example how to user Retry Queue pattern include Parking Queue
- Example how to crerate/delete RabbiMQ configuration using admin Rest API
- Example how to publish/consume messages using admin Rest API

## Run it in docker composer

 - Clone repo to your host

 - go to folder /tests and prepare credentials RabbitMQ in .sh files

 ```bash
    # RabbitMQ Test Credentials
    export XUSR=<RabbitMQ user>
    export XPSW=<RabbitMQ password>
 ```

- go to folder /msg-srvc and prepare credentials RabbitMQ in .env file

```text
    RMQ_USR=<RabbitMQ user>
    RMQ_PSW=<RabbitMQ password>
```

- install Node.js dependecies in folder /msg-srvc

go to folder and run this command:
```bash
  # run command
  npm install
```

 - run RabbitMQ using docker composer 

```bash
    docker-compose -f  docker-compose.yml up --remove-orphans --force-recreate --build -d
```

when it starts RabbitMQ UI can be reached on http://localhost:15672/

- create RabbitMQ configuratrion

run sh script

```bash
/test/create-cfg.sh
```
It creates two exchanges: main-exchange, retry-exchange and four queues: main-queue, reply-queue, retry-queue, parking-queue.

- run publisher in folder /msg-srvc to publish normal messages 


check that in msg-srvc/publisher.js  the "amount" key has value less then 100.00
For example:
```js
const msg = {"num": 1000, "dbt": "1001001", "krd": "1007222", "amount": 10.23, "remark": "cash payment"};
```

If not so, change it.
This message wiil be procesed and response message will be send in reply_queue

```bush
  npm run pub
```
- run publisher in folder /msg-srvc to publish pison message

This message will be send into retry queue and finally in parking queue
check that in msg-srvc/publisher.js   the amount more 100.00
For example:
```js
const msg = {"num": 1000, "dbt": "1001001", "krd": "1007222", "amount": 210.23, "remark": "cash payment"};
```
If not so, change it.

- run consumer in folder /msg-srvc for  processing message


```bush
  npm run con
```

Waiting until the message appears in the log 

```text
Message sent to parking queue
```

- stop consuming by CTRL + C

check how to messages transfers between queues.

- stop docker composer


```bash
   docker-compose -f  docker-compose.yml  stop
```


