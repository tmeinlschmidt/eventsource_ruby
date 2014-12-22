require 'http/parser'

module EventsourceRuby

  class RequestParser
    extend Forwardable

    attr_reader :headers
    attr_reader :body
    attr_reader :request_url
    attr_accessor :processor
    attr_accessor :socket
    attr_accessor :persistent_socket

    CONNECTING    = 1
    HEADERS       = 2
    MSG_COMPLETED = 3

    delegate [:status_code, :<<, :request_url, :headers, :http_method] => :@parser

    def initialize
      @parser = Http::Parser.new(self)
      reset!
    end

    def post?
      http_method == 'POST'
    end

    def get?
      http_method == 'GET'
    end

    def update?
      http_method == 'UPDATE'
    end

    def reset!
      @headers = nil
      @body = ''
      @status = CONNECTING
      @persistent_socket = false
    end

    def on_message_complete
      @status = MSG_COMPLETED
      puts "*** msg complete"
      p headers
      p body
      p request_url
      p status_code
      processor.process(self) if processor
    end

    def completed?
      @status == MSG_COMPLETED
    end

    def on_body(chunk)
      puts "*** on body #{chunk}"
      @body << chunk
    end

    def on_headers_complete(headers)
      puts "*** headers complete"
      @status = HEADERS
      @headers = headers
    end

    def headers?
      !!@headers
    end

    def status
      @parser.status
    end

  end

end
