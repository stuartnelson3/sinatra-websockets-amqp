require 'sinatra'
require 'sinatra-websocket'
require 'amqp'

get '/' do
  if !request.websocket?
    erb :index
  else

    request.websocket do |ws|
      connection = AMQP.connect(host: '127.0.0.1')
      channel    = AMQP::Channel.new(connection)
      exchange   = channel.fanout("test.fanout")
      queue      = AMQP::Queue.new(channel, "", :auto_delete => true)

      queue.bind(exchange).subscribe do |meta_data, payload|
        ws.send(payload)
      end

      ws.onopen do
        ws.send("Hello World!")
      end

      ws.onmessage do |msg|
        EM.next_tick { exchange.publish(msg) }
      end

      ws.onclose do
        warn("wetbsocket closed")
        queue.delete
      end
    end
  end
end