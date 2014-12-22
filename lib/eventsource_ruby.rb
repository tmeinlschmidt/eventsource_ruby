require 'eventsource_ruby/version.rb'

require 'json'

module EventsourceRuby

  DEFAULT_OPTIONS = {
    workers: 10,
    host: '127.0.0.1',
    listener_port: 8888
  }

  class << self

    def options
      @options ||= DEFAULT_OPTIONS
    end

    def options=(opts = {})
      @options = opts
    end

  end

end
