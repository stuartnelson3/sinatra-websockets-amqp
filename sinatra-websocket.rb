require 'sinatra'
require 'sinatra-websocket'
require 'amqp'

# set :port, 5672
set :server, 'thin'
set :sockets, []

get '/' do
  if !request.websocket?
    erb :index
  else
    connection = AMQP.connect(host: '127.0.0.1')
    channel  = AMQP::Channel.new(connection)
    exchange = channel.fanout("test.fanout")
    channel.queue("").bind(exchange).subscribe do |meta_data, payload|
      settings.sockets.each {|s| s.send(payload)}
    end

    request.websocket do |ws|
      start_time = Time.now
      ws.onopen do
        ws.send("Hello World!")
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        EM.next_tick { exchange.publish(msg) } # settings.sockets.each {|s| s.send(msg) }
      end
      ws.onclose do
        warn("wetbsocket closed")
        settings.sockets.delete(ws)
      end

      # EM.add_periodic_timer(2) do
      #   settings.sockets.each {|s| s.send("#{Time.now}. Server up for #{Time.now - start_time} seconds.")}
      # end
    end
  end
end

__END__
@@ index
<html>
  <body>
     <h1>Simple Echo & Chat Server</h1>
     <div id="msgs"></div>
     <form id="form">
       <input type="text" id="input" value="send a message"></input>
     </form>
  </body>

  <script type="text/javascript">
    window.onload = function(){
      (function(){
        var show = function(el){
          return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
        }(document.getElementById('msgs'));

        var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
        ws.onopen    = function()  { show('websocket opened'); };
        ws.onclose   = function()  { show('websocket closed'); }
        ws.onmessage = function(m) { show('websocket message: ' +  m.data); };

        var sender = function(f){
          var input     = document.getElementById('input');
          input.onclick = function(){ input.value = "" };
          f.onsubmit    = function(){
            ws.send(input.value);
            input.value = "";
            return false;
          }
        }(document.getElementById('form'));
      })();
    }
  </script>
</html>