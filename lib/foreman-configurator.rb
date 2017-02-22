require 'foreman-configurator/config'
require 'foreman-configurator/connection'
require 'foreman-configurator/models/architecture'
require 'foreman-configurator/models/partition-table'

module ForemanConfigurator
  def self.connection
    @@connection
  end

  def self.update_resources(config, klass)
    # Get all existing resources
    resources = klass.all

    # For each managed resource
    @@config[config].each do |_, params|
      # Look for an existing version
      resource = resources.find{|x| x.get(:name) == params[:name]}

      # If it doesn't exist create it
      unless resource
        resource = klass.new
        resource.created = true
        resources << resource
      end

      # Iterate over any parameters specified
      params && params.each do |k, v|
        # If it's a file reference load up that file as the value
        if v.start_with?('file:///')
          v = File.open(v[8..-1]).read
        end
        # And set the parameter value
        resource.set(k, v)
      end

      # Flag the resource is managed
      resource.managed = true
    end

    # Commit any managed and modified resources
    resources.select(&:modified).map(&:commit)

    # Purge any unmanaged resources
    resources.reject(&:managed).map(&:delete)

    # Return the managed resources
    resources.select(&:managed)
  end

  def self.run!
    # Load the configuration file and prevent modification
    @@config = Config.new('config.yaml')
    @@config.freeze

    # Create a global connection object to be used by the models
    @@connection = Connection.new(@@config)

    # Install architectures
    update_resources('architectures', ForemanConfigurator::Models::Architecture)

    # Install partiton tables
    update_resources('partition_tables', ForemanConfigurator::Models::PartitionTable)

  end
end
