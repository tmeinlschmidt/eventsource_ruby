require 'eventsource_ruby/listener'
require 'eventsource_ruby/subscriber'
require 'eventsource_ruby/publisher'

module EventsourceRuby

  class Launcher

    attr_accessor :listener
    attr_accessor :subscriber
    attr_accessor :publisher

    def initialize(options = {})
      @listener = EventsourceRuby::Listener.new(options)
      @publisher = EventsourceRuby::Publisher.new(options)
      @subscriber = EventsourceRuby::Subscriber.new(options)
    end

    def run
      listener.run
      sleep 1
    end

    def stop
      listener.async.stop
    end

  end

end
