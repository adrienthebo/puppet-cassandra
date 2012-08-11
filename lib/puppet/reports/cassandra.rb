# This is based off of the bunraku redis report processor
# See https://github.com/jamtur01/bunraku/blob/master/bunraku-report/lib/puppet/reports/bunraku.rb

begin
  require 'rubygems'
  require 'cassandra'
rescue LoadError => e
  Puppet.info "The cassandra report processor requires the 'cassandra' gem"
end

Puppet::Reports.register_report(:cassandra) do

  desc <<-EOD
Submit reports to cassandra.
  EOD

  def process
    require 'cassandra'
    client = Cassandra.new('puppet', '127.0.0.1:9160')
    client.insert(:reports, self.host, {Time.now.strftime("%Y-%m-%d %H:%M:%S") => format})
  rescue => e
    Puppet.warning "Unable to submit report to Cassandra: #{e}: #{e.backtrace.first}"
  end

  def format
    h = {
      :time           => self.time,
      :node           => self.host,
      :status         => self.status,
      :kind           => self.kind,
      :config_version => self.configuration_version,
      :environment    => self.environment,
      :metrics        => extract_metrics,
      :logs           => extract_logs,
    }

    PSON.generate h
  end

  # Returns a hash with a key of the metric class, and then a hash of the metric names and values.
  def extract_metrics
    h = {}
    self.metrics.each_pair do |name, metric|
      metrics = {}

      h[name] = metric.values.inject({}) do |hash, row|
        hash[row[0]] = row[2]
        hash
      end
    end
  end

  def extract_logs
    self.logs.map { |log| {:message => log.message, :level => log.level, :time => log.time} }
  end
end
