require 'foreman-configurator/model'
require 'foreman-configurator/collector-deep'

module ForemanConfigurator
  module Models
    class PartitionTable
      include ForemanConfigurator::Model
      extend ForemanConfigurator::CollectorDeep

      path '/api/ptables'
      attributes :name, :id, :os_family, :layout

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
