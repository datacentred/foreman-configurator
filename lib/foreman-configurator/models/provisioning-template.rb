require 'foreman-configurator/model'
require 'foreman-configurator/collector-deep'

module ForemanConfigurator
  module Models
    class ProvisioningTemplate
      include ForemanConfigurator::Model
      extend ForemanConfigurator::CollectorDeep

      path '/api/config_templates'
      attributes :name, :id, :snippet, :template_kind_id, :template, :locked

      # Return all provisioning template resources on the server
      # This is a two stage lookup as listing doesn't return the
      # actual layout
      def self.all
        resources = ForemanConfigurator.connection.get(path_get, true)
        resources.map do |resource|
          new(ForemanConfigurator.connection.get("#{path_get}/#{resource['id']}"))
        end
      end

      # Commit the new resource to the server
      def commit
        # Generic partition table data
        data = {
         'config_template' => attributes,
        }
        # Method specific setup
        if created
          method = :post
          uri = self.class.path_get
        else
          method = :put
          uri = "#{self.class.path_get}/#{get(:id)}"
        end
        # Commit and update attributes
        res = ForemanConfigurator.connection.send(method, uri, data)
        set :id, res['id']
      end

      # Delete a resource from the server
      def delete
        ForemanConfigurator.connection.delete("#{self.class.path_get}/#{get('id')}")
      end
    end
  end
end
