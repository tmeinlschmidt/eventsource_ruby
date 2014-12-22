require 'cgi'
require 'uri'

module EventsourceRuby

  class ListenerHandler
    include Celluloid::Notifications

    extend Forwardable

    attr_reader :path
    attr_reader :body

    delegate [:get?, :post?, :update?, :body, :headers, :socket] => :@parser

    def initialize
      @on = {}
    end

    def when(url, &block)
      @on[url] = block
    end

    def process(parser)
      load_parser(parser)

      return if @on.empty?
      @on.each do |url, block|
        instance_eval(&block) if url == path
      end
    end

    def persistent_socket
      @parser.persistent_socket = true
    end

    private

    def load_parser(parser)
      @parser = parser
      @params = parse_params(parser.request_url)
      @path = parse_request_url(parser.request_url)
    end

    def parse_params(uri)
      query = URI.parse(uri).query
      return nil unless query
      CGI.parse(query)
    end

    def parse_request_url(uri)
      URI.parse(uri).path
    end

  end

end
