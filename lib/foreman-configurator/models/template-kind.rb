require 'foreman-configurator/model'
require 'foreman-configurator/collector'

module ForemanConfigurator
  module Models
    class TemplateKind
      include ForemanConfigurator::Model
      extend ForemanConfigurator::Collector

      path '/api/template_kinds'
      attributes :name, :id

    end
  end
end
