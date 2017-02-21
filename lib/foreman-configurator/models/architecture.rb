require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class Architecture
      include ForemanConfigurator::Model

      attributes :id

      # Return all architecture resources on the server
      def self.all
        resources = ForemanConfigurator.connection.get('/api/architectures', true)
        resources.map{|x| Architecture.new(x['name'], x)}
      end

      # Commit the new resource to the server
      def commit
        data = {
          'architecture' => {
            'name' => name,
          }
        }
        res = ForemanConfigurator.connection.post('/api/architectures', data)
        set('id', res['id'])
      end

      # Delete a resource from the server
      def delete
        ForemanConfigurator.connection.delete("/api/architectures/#{get('id')}")
      end
    end
  end
end
