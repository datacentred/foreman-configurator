require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class SmartProxy
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::Collector
      include ForemanConfigurator::Model::Backend::Emitter

      attributes :name, :id, :url
      parameters :smart_proxy
    end
  end
end
