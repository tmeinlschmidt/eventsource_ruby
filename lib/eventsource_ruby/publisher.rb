module EventsourceRuby

  class Publisher
    include Celluloid
    include Celluloid::Notifications

    def initialize(options = {})
      subscribe 'publish', :on_publish
    end

    def on_publish(*args)
      _, message = args
      puts "-> observer #{message}"
      publish 'dispatch', message
    end

  end

end
