require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class Architecture
      include ForemanConfigurator::Model

      path '/api/architectures'
      attributes :name, :id

      # Return all architecture resources on the server
      def self.all
        resources = ForemanConfigurator.connection.get(path_get, true)
        resources.map{|x| Architecture.new(x)}
      end

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
