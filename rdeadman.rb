require 'net/ping'
require 'curses'
require 'socket'

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
    Curses.curs_set(0)
    Curses.start_color
    Curses.use_default_colors
    Curses.init_pair(1, Curses::COLOR_GREEN, -1)
    Curses.init_pair(2, Curses::COLOR_RED, -1)
  end

  def close
    Curses.close_screen
  end

  def draw(host_monitor)
    Curses.clear
    draw_title(host_monitor)
    draw_reference
    draw_host_status(host_monitor)
    Curses.refresh
  end

  def draw_title(host_monitor)
    Curses.setpos(0, 0)
    Curses.addstr(" From: #{Socket.gethostname} (#{host_monitor.address}) [ver 22.02.10]")
    Curses.setpos(1, 0)
    Curses.addstr("   RTT Scale 10ms. Keys: (r)efresh")
  end

  def draw_reference
    Curses.setpos(3, 0)
    Curses.addstr(" HOSTNAME  ADDRESS             LOSS  RTT  AVG  SNT  RESULT")
  end

  def draw_host_status(host_monitor)
    Curses.setpos(4, 0)
    status = [
      host_monitor.host.ljust(8),
      host_monitor.address.ljust(15),
      "#{host_monitor.loss_rate}%",
      "#{host_monitor.results.last}",
      "#{host_monitor.avg_rtt}",
      "#{host_monitor.sent_packets}",
      "#{host_monitor.result_graph}"
    ].join("  ")

    Curses.addstr(status)
  end
end

if ARGV.length < 1
  puts "Usage: ruby monitor_host.rb <host> [interval]"
  exit
end

host = ARGV[0]
interval = ARGV[1] ? ARGV[1].to_i : 5

monitor = HostMonitor.new(host, interval)
display = Display.new

begin
  monitor.monitor do |host_monitor|
    display.draw(host_monitor)
  end
ensure
  display.close
end
