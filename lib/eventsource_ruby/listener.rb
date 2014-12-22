require 'celluloid/io'
require 'eventsource_ruby/request_parser'
require 'eventsource_ruby/listener_handler'

module EventsourceRuby

  class Listener
    include Celluloid::IO

    MAX_BUF = 4096

    finalizer :shutdown

    def initialize(options = {})
      @server = TCPServer.new(options[:host], options[:listener_port])
      @parser = EventsourceRuby::RequestParser.new
      handler = EventsourceRuby::ListenerHandler.new

      handler.when '/publish' do
        puts "body je #{JSON.parse(body)}" if post?
        publish 'publish', body
      end

      handler.when '/subscribe' do
        persistent_socket
        publish 'subscribe', socket
      end

      @parser.processor = handler
    end

    def run
      async.run_loop
    end

    def run_loop
      loop { async.handle_connection(@server.accept) }
    end

    def shutdown
      @server.close if @server
    end

    def handle_connection(socket)
      @parser.reset!
      @parser.socket = socket
      _, port, host = socket.peeraddr
      puts "*** Received connection from #{host}:#{port}"

      while !@parser.completed? do
        @parser << socket.readpartial(MAX_BUF)
        puts "."
      end

      send_response(socket) unless @parser.persistent_socket
      rescue IOError, Errno::ECONNRESET, Errno::EPIPE, EOFError
        puts "*** #{host}:#{port} disconnected"
      ensure
        unless @parser.persistent_socket
          puts "*** socket closed"
          socket.close unless socket.closed?
        end
    end

    def send_response(socket)
      msg = "Hello World \r\n"
      socket.write("HTTP/1.1 200 \r\n")
      socket.write("Content-Type: text/html\r\n")
      socket.write("Content-Length: #{msg.length}\r\n")
      socket.write("Status 200 \r\n")
      socket.write("Connection: close \r\n")
      socket.write("\r\n\r\n")
      socket.write(msg)
      rescue Errno::EPIPE
        nil
    end

    def stop
      shutdown
    end

  end

end
