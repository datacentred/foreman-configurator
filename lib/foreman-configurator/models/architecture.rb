require 'foreman-configurator/model'
require 'foreman-configurator/collector'

module ForemanConfigurator
  module Models
    class Architecture
      include ForemanConfigurator::Model
      extend ForemanConfigurator::Collector

      path '/api/architectures'
      attributes :name, :id

      # Commit the new resource to the server
      def commit
        data = {
          'architecture' => attributes,
        }
        res = ForemanConfigurator.connection.post(self.class.path_get, data)
        set('id', res['id'])
      end

      # Delete a resource from the server
      def delete
        ForemanConfigurator.connection.delete("#{self.class.path_get}/#{get('id')}")
      end
    end
  end
end
