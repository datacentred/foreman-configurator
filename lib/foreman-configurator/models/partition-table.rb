module ForemanConfigurator
  module Models
    class PartitionTable

      attr_accessor :id, :name, :os_family, :layout

      alias_method :to_s, :inspect

      # Return all partition table resources on the server
      # This is a two stage lookup as listing doesn't return the
      # actual layout
      def self.all
        resources = ForemanConfigurator.connection.get('/api/ptables', true)
        resources.map do |resource|
          pt = ForemanConfigurator.connection.get("/api/ptables/#{resource['id']}")
          PartitionTable.new(pt['name'], pt['layout'], pt['os_family'], pt['id'])
        end
      end

      def initialize(name, layout, os_family, id=nil)
        @name = name
        @layout = layout
        @os_family = os_family
        @id = id
      end

      def ==(other)
        name == other.name
      end

      # Commit the new resource to the server
      def commit
        data = {
          'name' => @name,
          'layout' => @layout,
          'os_family' => @os_family,
        }
        res = ForemanConfigurator.connection.post('/api/ptables', data)
        @id = res['id']
      end

      # Delete a resource from the server
      def delete
        ForemanConfigurator.connection.delete("/api/ptables/#{@id}")
      end
    end
  end
end
