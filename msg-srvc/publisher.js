const amqp = require('amqplib');
const dotenv = require('dotenv');
dotenv.config();
const { v4: uuidv4 } = require('uuid');


async function publish() {
    const correlationId = uuidv4();
    const replyToQueue  = "reply-queue";
    const exchange= "main-exchange";
    const routingKey = "srvc.transact.cash";
    const msg = {"num": 1000, "dbt": "1001001", "krd": "1007222", "amount": 210.23, "remark": "cash payment"};

    // Connect to RabbitMQ
    const irmq_usr  = process.env.RMQ_USR;
    const irmq_psw = process.env.RMQ_PSW;
    const irmq_host = process.env.RMQ_HOST;
    const irmq_port = process.env.RMQ_PORT;
    const irmq_url=`amqp://${irmq_usr}:${irmq_psw}@${irmq_host}:${irmq_port}`;
    const conn = await amqp.connect(irmq_url);
    const channel = await conn.createChannel();
    // Publish message to the exchange with routing key
    channel.publish(exchange, routingKey, Buffer.from( JSON.stringify(msg) ),
                { 
                    persistent: true,
                    correlationId: correlationId,
                    replyTo: replyToQueue,
                    contentType: 'application/json',
                    headers: {
                        'x-cerrelation-id': correlationId,
                        'x-request-type': 'cash-transaction'

                    }
                }); 
            

    console.log(` [x] Sent '${JSON.stringify(msg)}' with routing key '${routingKey}'`);

    setTimeout(() => {
        channel.close();
        conn.close();
    }, 500);
}

publish().catch(console.error);