require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class PartitionTable
      include ForemanConfigurator::Model

      attributes :id, :os_family, :layout

      # Return all partition table resources on the server
      # This is a two stage lookup as listing doesn't return the
      # actual layout
      def self.all
        resources = ForemanConfigurator.connection.get('/api/ptables', true)
        resources.map do |resource|
          pt = ForemanConfigurator.connection.get("/api/ptables/#{resource['id']}")
          PartitionTable.new(pt['name'], pt)
        end
      end

      # Commit the new resource to the server
      def commit
        if created
          data = {
            'name' => name,
            'layout' => get('layout'),
            'os_family' => get('os_family'),
          }
          res = ForemanConfigurator.connection.post('/api/ptables', data)
          set('id', res['id'])
        else
          data = {
            'id' => get('id'),
            'ptable' => {
              'name' => name,
              'layout' => get('layout'),
              'os_family' => get('os_family'),
            }
          }
          ForemanConfigurator.connection.put("/api/ptables/#{get('id')}", data)
        end
      end

      # Delete a resource from the server
      def delete
        ForemanConfigurator.connection.delete("/api/ptables/#{get('id')}")
      end
    end
  end
end
