require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class Architecture
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::Collector
      include ForemanConfigurator::Model::Backend::Emitter

      attributes :name, :id
      parameters :architecture
    end
  end
end
