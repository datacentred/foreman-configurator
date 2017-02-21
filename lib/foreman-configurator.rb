require 'foreman-configurator/config'
require 'foreman-configurator/connection'
require 'foreman-configurator/models/architecture'
require 'foreman-configurator/models/partition-table'

module ForemanConfigurator
  def self.connection
    @@connection
  end

  def self.run!
    # Load the configuration file and prevent modification
    @@config = Config.new('config.yaml')
    @@config.freeze

    # Create a global connection object to be used by the models
    @@connection = Connection.new(@@config)

    # Install architectures that aren't known about
    resources = ForemanConfigurator::Models::Architecture.all
    managed = @@config['architectures'].map do |name|
      resource = resources.find{|x| x.name == name}
      unless resource
        resource = ForemanConfigurator::Models::Architecture.new(name)
        resource.commit
      end
      resource
    end
    # Purge any unmanaged resources
    resources.reject{|x| managed.include?(x)}.each(&:delete)

    # Install partiton tables that aren't known about
    resources = ForemanConfigurator::Models::PartitionTable.all
    managed = @@config['partition_tables'].map do |name, params|
      resource = resources.find{|x| x.name == name}
      unless resource
        # Hack: strips off the 'file:///' header
        layout = File.open(params['layout'][8..-1]).read
        resource = ForemanConfigurator::Models::PartitionTable.new(name, layout, params['os_family'])
        resource.commit
      end
      resource
    end
    # Purge any unmanaged resources
    resources.reject{|x| managed.include?(x)}.each(&:delete)

  end
end
