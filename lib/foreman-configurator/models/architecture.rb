module ForemanConfigurator
  module Models
    class Architecture

      attr_accessor :id, :name

      alias_method :to_s, :inspect

      # Return all architecture resources on the server
      def self.all
        resources = ForemanConfigurator.connection.get('/api/architectures', true)
        resources.map{|x| Architecture.new(x['name'], x['id'])}
      end

      # Create a new architecture resource
      def initialize(name, id=nil)
        @name = name
        @id = id
      end

      def ==(other)
        name == other.name
      end

      # Commit the new resource to the server
      def commit
        data = {
          'architecture' => {
            'name' => @name,
          }
        }
        res = ForemanConfigurator.connection.post('/api/architectures', data)
        @id = res['id']
      end

      # Delete a resource from the server
      def delete
        ForemanConfigurator.connection.delete("/api/architectures/#{@id}")
      end
    end
  end
end
