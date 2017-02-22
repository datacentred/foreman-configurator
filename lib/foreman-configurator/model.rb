require 'active_support/inflector'

module ForemanConfigurator
  module Model
    # Attributes are mutable parameters associated with a resource
    # * A whitelist of class instance variables defines which attributes we
    #   will accept from Foreman or configuration
    # * Attributes are stored as a hash whose keys are always symbols
    #   and can be used directly as a POST/PUT query against the Foreman API
    module Attributes
      attr_accessor :modified
      attr_accessor :managed
      attr_accessor :created
      attr_accessor :attributes

      def initialize(init={})
        # Translate initialization data keys to symbols: handles raw tainted input from foreman
        init = init.map{|k, v| [k.to_sym, v]}.to_h
        # Select whitelisted attributes from the initial data
        @attributes = init.select{|attr| self.class.attributes_get.include?(attr)}
        # Set instance defaults
        @modified = false
        @managed = false
        @created = false
      end

      def get(attr)
        attr = attr.to_sym
        @attributes[attr]
      end

      def set(attr, new)
        attr = attr.to_sym
        old = get(attr)
        if old.nil? || old != new
          @modified = true
        end
        @attributes[attr] = new
      end

      module ClassMethods
        def attributes(*attr)
          @whitelist = attr
        end

        def attributes_get
          @whitelist
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end

    module Backend
      # Common backend requirements for each resource type
      # * Caches the Foreman API URI path for use by collectors and commiters
      module Common
        module ClassMethods
          def parameters(noun)
            @noun = noun
          end

          def uri(*path)
            path.unshift('/api/' + @noun.to_s.pluralize).join('/')
          end

          def noun
            @noun
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end
      end

      # Basic collector
      # * Returns a list of all resources found via the API
      # * All attributes are returned by a simple list operation
      module Collector
        module ClassMethods
          def all
            resources = ForemanConfigurator.connection.get(uri, true)
            resources.map{|x| new(x)}
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end
      end

      # Deep collector
      # * Returns a list of all resources found via the API
      # * All attributes are returned by an API lookup of a specific resource ID
      #   and not via a simple list operation
      module CollectorDeep
        module ClassMethods
          def all
            resources = ForemanConfigurator.connection.get(uri, true)
            resources.map do |resource|
              new(ForemanConfigurator.connection.get(uri(resource['id'])))
            end
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end
      end

      # Emitter
      # * Sets the resource via the API
      module Emitter
        def commit
          data = {self.class.noun => attributes}
          if created
            method = :post
            path = self.class.uri
          else
            method = :put
            path = self.class.uri(get(:id))
          end
          res = ForemanConfigurator.connection.send(method, path, data)
          set(:id, res['id'])
        end

        # Delete a resource from the server
        def delete
          ForemanConfigurator.connection.delete(self.class.uri(get('id')))
        end
      end
    end
  end
end
