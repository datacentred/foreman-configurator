require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class PartitionTable
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::CollectorDeep
      include ForemanConfigurator::Model::Backend::Emitter

      attributes :name, :id, :os_family, :layout
      parameters :ptable
    end
  end
end
