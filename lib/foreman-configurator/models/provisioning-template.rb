require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class ProvisioningTemplate
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::CollectorDeep
      include ForemanConfigurator::Model::Backend::Emitter

      attributes :name, :id, :snippet, :template_kind_id, :template, :locked
      parameters :config_template
    end
  end
end
