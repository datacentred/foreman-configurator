require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class Medium
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::Collector
      include ForemanConfigurator::Model::Backend::Emitter

      attributes :name, :id, :os_family, :path
      parameters :medium
    end
  end
end
