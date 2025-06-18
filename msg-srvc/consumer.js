const amqp = require('amqplib');
require('dotenv').config();

async function consume() {
    const exchange = "main-exchange";
    const routingKey = "srvc.transact.cash";
    const queue = "main-queue";
    const parking_queue = "parking-queue";
    const MAX_RETRY = 3;


    // Conection params
    const irmq_usr  = process.env.RMQ_USR;
    const irmq_psw = process.env.RMQ_PSW;
    const irmq_host = process.env.RMQ_HOST;
    const irmq_port = process.env.RMQ_PORT;
    const irmq_url = `amqp://${irmq_usr}:${irmq_psw}@${irmq_host}:${irmq_port}`;
    // Connect to RabbitMQ
    const conn = await amqp.connect(irmq_url);
    const channel = await conn.createChannel();


    console.log(" [*] Waiting for messages. To exit press CTRL+C");

    channel.consume(queue, async (msg) => {
        if (msg !== null) {
            try {

                const content = msg.content.toString();
                const correlationId = msg.properties.correlationId;
                const contentType = msg.properties.contentType;

                // ...incide consumer ...

                // Check if the message has been retried too many times
                // and route it to the parking queue if so
                const xDeath = msg.properties.headers['x-death'];
                let retryCount = 0;
                if (xDeath && Array.isArray(xDeath) && xDeath.length > 0) {
                    retryCount = xDeath[0].count;
                }

                if (retryCount >= MAX_RETRY) {
                    // Route to  parking queue after max retries 
                    channel.sendToQueue( parking_queue, msg.content, msg.properties);
                    channel.ack(msg);
                    console.log('Message sent to parking queue');
                    return;
                } 

               
                console.log('Retry count:', retryCount);   
                console.log('Retry count:', JSON.stringify(xDeath, null,2));                             

                console.log(" [x] Received message with correlationId:", correlationId);
                console.log(" [x] Received message with contentType:", contentType);
                console.log(" [x] Received:", content);

                if (contentType !== 'application/json') {
                    console.error(" [!] Invalid content type:", contentType);
                    // Incase of contetn type is not JSON, NACK з requeue=false (for DLX/retry)
                    channel.nack(msg, false, false);
                    console.log(" [x] Message NACKed due to invalid content type");
                    return;                     
                }
                const parsedContent = JSON.parse(content);
                console.log(" [X] Parsing content: ok");
                
                // Validate the parsed content
                // For example, check if amount within a certain range
                if (parsedContent.amount > 100.00) {
                    console.error(" [!] Amount exceedds limit:", parsedContent.amount);
                    channel.nack(msg, false, false);
                    console.log(" [x] Message NACKed due to invalid amount");
                    return;       

                }
                
                // For instance, if all is ok, we can ACK this message:
                channel.ack(msg);
                console.log(" [x] Message ACKed");

                // And publish reply in  replyTo queue:
                if (msg.properties.replyTo) {
                    channel.sendToQueue(
                        msg.properties.replyTo,
                        Buffer.from('{"status":"ok"}'),
                        { correlationId: msg.properties.correlationId, contentType: 'application/json' }
                    );
                }
            } catch (err) {
                console.error(" [!] Error processing message:", err);
                // If error — NACK with requeue=false (for DLX/retry)
                channel.nack(msg, false, false);
                console.log(" [x] Message NACKed");
            }
        }
    }, { noAck: false });
}

consume().catch(console.error);