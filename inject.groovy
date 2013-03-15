import com.rabbitmq.client.*
import java.util.Random  
 
@Grab(group='com.rabbitmq', module='amqp-client', version='1.7.2')
params = new ConnectionParameters(
    username: 'guest',
    password: 'guest',
    virtualHost: '/',
    requestedHeartbeat: 0
)
factory = new ConnectionFactory(params)
conn = factory.newConnection('127.0.0.1', 5672)
channel = conn.createChannel()
exchangeName = 'stockExchange'
key = 'key.a'
 
Random rand = new Random()  
int max = 10  
while(true){
 
    int next = rand.nextInt(max+1)  
    String msg = "${next}"
    channel.basicPublish(exchangeName, key , MessageProperties.TEXT_PLAIN , msg.bytes)
    Thread.sleep(300)
}
 
channel.close()
conn.close()
