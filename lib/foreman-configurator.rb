require 'foreman-configurator/config'
require 'foreman-configurator/connection'
require 'foreman-configurator/models/architecture'
require 'foreman-configurator/models/partition-table'
require 'foreman-configurator/models/template-kind'
require 'foreman-configurator/models/provisioning-template'
require 'foreman-configurator/models/medium'

module ForemanConfigurator
  def self.connection
    @@connection
  end

  def self.update_resources(config, klass)
    # Get all existing resources
    resources = klass.all

    # Make locked resources managed
    resources.each{|x| x.managed = true if x.get(:locked)}

    # For each managed resource
    @@config[config].each do |params|
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
        if v.is_a?(String)
          if v.start_with?('file:///')
            v = File.open(v[8..-1]).read
          elsif v.start_with?('resource:///')
            type, name, attribute = v[12..-1].split('/')
            ext_resources = ForemanConfigurator::Models.const_get(type).all
            ext_resource = ext_resources.find{|x| x.get(:name) == name}
            v = ext_resource.get(attribute.to_sym)
          end
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

    # Install provisioning templates
    update_resources('provisioning_templates', ForemanConfigurator::Models::ProvisioningTemplate)

    # Install media
    update_resources('media', ForemanConfigurator::Models::Medium)
  end
end
