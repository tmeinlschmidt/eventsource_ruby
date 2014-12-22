module EventsourceRuby

  class Subscriber
    include Celluloid
    include Celluloid::Notifications

    def initialize(options = {})
      @subscribers = []

      subscribe 'subscribe', :on_subscribe
      subscribe 'dispatch', :on_dispatch
    end

    def on_subscribe(*args)
      _, socket = args
      @subscribers << socket
      msg = "Hello World ...\r\n"
      socket.write("HTTP/1.1 200 \r\n")
      socket.write("Content-Type: text/event-stream\r\n")
      socket.write("\r\n\r\n")
      socket.write(msg)

      puts "-> observer #{args.inspect}"
    end

    def on_dispatch(*args)
      _, message = args
      @subscribers.each do |socket|
        async.dispatch(socket, message)
      end
    end

    private

    def dispatch(socket, message)
      socket.write("\r\n\r\n")
      socket.write("data: #{message}\n\n")
    end

  end

end
