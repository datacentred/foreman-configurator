require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class PartitionTable
      include ForemanConfigurator::Model

      path '/api/ptables'
      attributes :name, :id, :os_family, :layout

      # Return all partition table resources on the server
      # This is a two stage lookup as listing doesn't return the
      # actual layout
      def self.all
        resources = ForemanConfigurator.connection.get(path_get, true)
        resources.map do |resource|
          pt = ForemanConfigurator.connection.get("#{path_get}/#{resource['id']}")
          PartitionTable.new(pt)
        end
      end

      # Commit the new resource to the server
      def commit
        # Generic partition table data
        data = {
         'ptable' => attributes,
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
