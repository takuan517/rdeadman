# spec/monitor_spec.rb
require 'spec_helper'

RSpec.describe Rdeadman::HostMonitor do
  let(:host) { 'example.com' }
  let(:interval) { 1 }
  subject { described_class.new(host, interval) }

  describe '#initialize' do
    it 'initializes with the correct host and interval' do
      expect(subject.host).to eq(host)
      expect(subject.interval).to eq(interval)
    end
  end

  describe '#resolve_address' do
    it 'resolves the correct address for a given host' do
      expect(subject.resolve_address(host)).to be_a(String)
    end
  end

  describe '#monitor' do
    it 'monitors the host and updates results' do
      expect { |b| subject.monitor(&b) }.to change { subject.results.size }.by(1)
    end
  end

  describe '#loss_rate' do
    it 'calculates the correct loss rate' do
      subject.instance_variable_set(:@sent_packets, 10)
      subject.instance_variable_set(:@lost_packets, 2)
      expect(subject.loss_rate).to eq(20.0)
    end
  end

  describe '#avg_rtt' do
    it 'calculates the correct average RTT' do
      subject.instance_variable_set(:@results, [10.0, 20.0, 30.0])
      expect(subject.avg_rtt).to eq(20.0)
    end
  end
end

RSpec.describe Rdeadman::Display do
  let(:host_monitor) { instance_double(Rdeadman::HostMonitor, host: 'example.com', address: '93.184.216.34', loss_rate: 0.0, results: [10.0], avg_rtt: 10.0, sent_packets: 1, result_graph: '▁') }
  let(:display) { described_class.new }

  describe '#draw' do
    it 'draws the monitor display' do
      expect { display.draw([host_monitor]) }.not_to raise_error
    end
  end
end

RSpec.describe Rdeadman::MonitorHosts do
  describe '.load_hosts_from_config' do
    it 'loads hosts from a configuration file' do
      hosts = described_class.load_hosts_from_config('hosts.conf')
      expect(hosts).to be_an(Array)
      expect(hosts).to all(be_a(String))
    end
  end
end
