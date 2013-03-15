require "amqp"
# require "sinatra"
# require "em-websocket"

EventMachine.run do
  AMQP.connect(host: '127.0.0.1') do |connection|
    channel  = AMQP::Channel.new(connection)
    exchange = channel.fanout("test.fanout")

    channel.queue("").bind(exchange)
   
    # channel.queue("joe", :auto_delete => true).bind(exchange).subscribe do |payload|
    #   puts "#{payload} => joe"
    # end
   
    EM.add_periodic_timer(2) do
      exchange.publish("BOS 101, NYK 89").publish("ORL 85, ALT 88")   
    end
   
    # disconnect & exit after 2 seconds
    # EventMachine.add_timer(2) do
    #   exchange.delete
   
    #   connection.close { EventMachine.stop }
    # end
  end
end