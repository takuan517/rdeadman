# lib/rdeadman/monitor.rb
require 'net/ping'
require 'curses'
require 'socket'
require_relative 'version'

module Rdeadman
  class HostMonitor
    attr_reader :host, :address, :interval, :results, :sent_packets, :lost_packets

    def initialize(host, interval = 5)
      @host = host
      @address = resolve_address(host)
      @interval = interval
      @results = []
      @sent_packets = 0
      @lost_packets = 0
    end

    def resolve_address(host)
      IPSocket.getaddress(host)
    rescue SocketError
      "Unknown"
    end

    def monitor
      pinger = Net::Ping::External.new(@host)
      loop do
        @sent_packets += 1
        if pinger.ping
          rtt = (pinger.duration * 1000).round(2) # msに変換
          @results << rtt
        else
          @lost_packets += 1
          @results << "X"
        end
        yield self if block_given?
        sleep @interval
      end
    end

    def loss_rate
      (@lost_packets.to_f / @sent_packets * 100).round(2)
    end

    def avg_rtt
      avg = @results.select { |r| r.is_a?(Numeric) }.sum.to_f / @results.size
      avg.nan? ? 0 : avg.round(2)
    end

    def result_graph
      @results.map { |r| r.is_a?(Numeric) ? "▁" : "X" }.join
    end
  end

  class Display
    def initialize
      Curses.init_screen
      Curses.curs_set(0) # Invisible cursor
      Curses.start_color
      Curses.use_default_colors
      Curses.init_pair(1, Curses::COLOR_GREEN, -1)
      Curses.init_pair(2, Curses::COLOR_RED, -1)
    end

    def close
      Curses.close_screen
    end

    def draw(host_monitors)
      Curses.clear
      draw_title
      draw_reference
      host_monitors.each_with_index { |host_monitor, index| draw_host_status(host_monitor, index + 4) }
      Curses.refresh
    end

    def draw_title
      Curses.setpos(0, 0)
      Curses.addstr(" From: #{Socket.gethostname} [ver #{Rdeadman::VERSION}]")
      Curses.setpos(1, 0)
      Curses.addstr("   RTT Scale 10ms. Keys: (r)efresh")
    end

    def draw_reference
      Curses.setpos(3, 0)
      Curses.addstr(" HOSTNAME           ADDRESS             LOSS   RTT   AVG   SNT  RESULT")
    end

    def draw_host_status(host_monitor, line)
      Curses.setpos(line, 0)
      status = [
        host_monitor.host.ljust(16),
        host_monitor.address.ljust(17),
        "#{host_monitor.loss_rate}%".rjust(5),
        "#{host_monitor.results.last}".rjust(5),
        "#{host_monitor.avg_rtt}".rjust(5),
        "#{host_monitor.sent_packets}".rjust(5),
        "#{host_monitor.result_graph}"
      ].join("  ")

      Curses.addstr(status)
    end
  end

  module MonitorHosts
    def self.run(config_file, interval)
      hosts = load_hosts_from_config(config_file)
      host_monitors = hosts.map { |host| HostMonitor.new(host, interval) }
      display = Display.new

      begin
        threads = host_monitors.map do |monitor|
          Thread.new { monitor.monitor }
        end

        loop do
          display.draw(host_monitors)
          sleep interval
        end
      ensure
        display.close
        threads.each(&:kill)
      end
    end

    def self.load_hosts_from_config(file)
      hosts = []
      File.readlines(file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")
        hosts << line
      end
      hosts
    end
  end
end
