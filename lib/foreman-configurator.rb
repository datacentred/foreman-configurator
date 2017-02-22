require 'foreman-configurator/config'
require 'foreman-configurator/connection'
require 'foreman-configurator/models/architecture'
require 'foreman-configurator/models/partition-table'
require 'foreman-configurator/models/template-kind'
require 'foreman-configurator/models/provisioning-template'
require 'foreman-configurator/models/medium'
require 'foreman-configurator/models/operatingsystem'

module ForemanConfigurator
  def self.connection
    @@connection
  end

  def self.configure_dynamic(config)
    case config
    when String
      if config.start_with?('file:///')
        File.open(config[8..-1]).read
      elsif config.start_with?('resource:///')
        type, name, attribute = config[12..-1].split('/')
        ext_resources = ForemanConfigurator::Models.const_get(type).all
        ext_resource = ext_resources.find{|x| x.title == name}
        ext_resource.get(attribute.to_sym)
      else
        config
      end
    when Array
      config.map{|x| configure_dynamic(x)}.sort
    when Hash
      config.map{|k, v| [k.to_sym, configure_dynamic(v)]}.to_h
    else
      config
    end
  end

  def self.update_resources(config, klass)
    # Get all existing resources
    resources = klass.all

    # Make locked resources managed
    resources.each{|x| x.managed = true if x.get(:locked)}

    # For each managed resource
    @@config[config].each do |params|
      # Annoyingly the 'name' of operating systems isn't unique like all
      # the other resources.  Instead a composite title is composed of name,
      # major and minor revisions.  The models are allowed to define their own
      # titles.  Here we have to perform a minor hack with configuration
      # processing
      title = params[:title] || params[:name]

      # Look for an existing version
      resource = resources.find{|x| x.title == title}

      # If it doesn't exist create it
      unless resource
        resource = klass.new
        resource.created = true
        resources << resource
      end

      # Iterate over any parameters specified updating the resource
      configure_dynamic(params).each do |k, v|
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

    # Define the mapping of configuration items to models then perform
    # updates in order
    config_mapping = {
      'architectures'          => ForemanConfigurator::Models::Architecture,
      'partition_tables'       => ForemanConfigurator::Models::PartitionTable,
      'provisioning_templates' => ForemanConfigurator::Models::ProvisioningTemplate,
      'media'                  => ForemanConfigurator::Models::Medium,
      'operating_systems'      => ForemanConfigurator::Models::OperatingSystem,
    }
    config_mapping.each{|k, v| update_resources(k, v)}
  end
end
