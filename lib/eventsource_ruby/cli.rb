# encoding: utf-8

# write immediately to STDOUT
$stdout.sync = true

require 'singleton'
require 'optparse'

require 'eventsource_ruby'

module EventsourceRuby

  class CLI
    include Singleton

    attr_accessor :launcher

    def run(args = ARGV)
      if $stdout.tty?
        puts "\e[#{31}m"
        puts banner
        puts "\e[0m"
      end

      parse_options(args)

      if options[:daemonize] == true
        daemonize
        write_pid
      end

      load_celluloid
      boot
    end

    def handle_signal(signal)
      puts "got #{signal} signal"
      case signal
      when 'INT'
        launcher.stop
        raise Interrupt
      when 'TERM'
        raise Interrupt
      when 'USR1'
        puts 'stopping'
      when 'USR2'
        puts debug
      end
    end

    def boot
      self_read, self_write = IO.pipe

      %w(INT TERM USR1 USR2).each do |sig|
        begin
          trap sig do
            self_write.puts(sig)
          end
        rescue ArgumentError
          puts "Signal #{sig} not supported"
        end
      end

      require 'eventsource_ruby/launcher'
      @launcher = EventsourceRuby::Launcher.new(options)

      begin
        # start listeners here
        @launcher.run

        while readable_io = IO.select([self_read])
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue Interrupt
        launcher.stop
        exit(0)
      end
    end

    def parse_options(args)
      opts = OptionParser.new(&method(:set_opts))
      opts.parse!(args)
      options.merge!(@options)
    end

    protected

    def set_opts(opts)
      @options = {}

      opts.on('-w', '--workers [num]', 'Number of sender workers') do |arg|
        @options[:workers] = arg
      end

      opts.on('-l', '--logfile [PATH]', 'Path to logfile') do |arg|
        @options[:logfile] = arg
      end

      opts.on('-p', '--pidfile [PATH]', 'Path to pidfile') do |arg|
        @options[:pidfile] = arg
      end

      opts.on('-d', '--daemon', 'Daemonize') do |arg|
        @options[:daemonize] = arg
      end

      opts.on_tail('-v', '--version', 'Shows version') do
        puts "EventsourceRuby #{EventsourceRuby.version}"
        exit(0)
      end

      opts.on_tail('-h', '--help', 'Help message') do
        puts opts
        exit(0)
      end

      STDERR.puts @_options
    end

    private

    def banner
%q{
`````````````````````````````````````````````````````````
.,:::::,.`.,:::::,,..,:::::,..,::,.    ,,:::,,..,:,..,:,.
,#######:.,########,,########,####.`   `######,.###,,###.
,########,,########,,########,:###.`   .######,,###::###.
.###::###,,###::###,,###::###::###.    .######,.:##::###.
.###::###,,###,,###.,###::###::###.    .######,.,###:##:`
.###,,###,,###,...``,###,,###::###.   `.######:.,######,`
.###,,###,,###:,`` `.###,,###::###.   `.###:##:..######.`
.###::###,,#####.` `.###::###::###.   `.###:###..:#####.
.###:####,,#####.` `.###::###,:###.`  `,###:###..,####:`
.#######:,,###:.````.#######,.,###.```.,###:###,`.####,`
.########,,###,.....,####:,.`.,###,,::,:###:###,`.####,`
.###::###,,###,,###,,###:.`` `,###::##::###:###,..:###.`
.###:,###,,###::###,,###,`   `,###:###::#######:..:###.
.###,,###:,########,,###,`   `########::##::####..:###.
.###,,###:,########.::::,`   `,::#####,###:,:###..:###.
.###,,####.#:,,,...```.```   ``.........,,:.:###,.:###.
.####..,..```.```````.............```````````.,::.####.
:#:,.```````.....,,,,,...````...,,,,,.....````````.,:#.
```````...,,,`                          `.,,...````````
     `..             ###  # #:`### `          `,.`
    ``         ###: #:..# #:# `#., ####          `
     `,        #  # #   #:##  .### #  #        ..`
     `.,   #   ###. #   #.#:# ,#   ###.   #   ,.`
      `.,      #.   .### `# #,:### # #        ,`
      `.       #,                  # .#       ,`
      `,             ``....,...``             .`
      ``     .,,,.......```````......,,,.      .
      ` .,,...`````                ``````..,,. `

              Server Sent Event - Server}
    end

    def daemonize
      ::Process.daemon(true, true)
    end

    def write_pid
      if path = options[:pidfile]
        pidfile = File.expand_path(path)
        File.open(pidfile, 'w'){ |f| f.puts ::Process.pid }
      end
    end

    def load_celluloid
      require 'celluloid/autostart'
    end

    def options
      EventsourceRuby.options
    end

  end

end
