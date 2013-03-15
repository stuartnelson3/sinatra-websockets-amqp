require "amqp"

EventMachine.run do
  AMQP.connect(host: '127.0.0.1') do |connection|
    channel  = AMQP::Channel.new(connection)
    exchange = channel.fanout("test.fanout")
    channel.queue("").bind(exchange)
   
    # EM.add_periodic_timer(2) do
    #   exchange.publish("test publish 1").publish("test publish 2")
    # end
   
    # disconnect & exit after 2 seconds
    EventMachine.add_timer(2) do
      exchange.publish("test publish 1").publish("test publish 2")
      connection.close { EventMachine.stop }
    end
  end
end