require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class TemplateKind
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::Collector

      attributes :name, :id
      parameters :template_kind
    end
  end
end
