require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class Domain
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::Collector
      include ForemanConfigurator::Model::Backend::Emitter

      attributes :name, :id, :dns_id
      parameters :domain
    end
  end
end
