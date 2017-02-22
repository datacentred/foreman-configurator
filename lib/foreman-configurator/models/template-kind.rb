require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class TemplateKind
      include ForemanConfigurator::Model

      path '/api/template_kinds'
      attributes :name, :id

      # Return all template kind resources on the server
      def self.all
        resources = ForemanConfigurator.connection.get(path_get, true)
        resources.map{|x| TemplateKind.new(x)}
      end

    end
  end
end
