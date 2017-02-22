require 'active_support/inflector'

module ForemanConfigurator
  module Model

    # Attributes are mutable parameters associated with a resource
    #
    # A whitelist of class instance variables defines which attributes we
    # will accept from Foreman or configuration.Attributes are stored as a
    # hash whose keys are always symbols and can be used directly as a
    # POST/PUT query against the Foreman API.

    module Attributes

      # Has the instance been updated and needs to be updated in Foreman
      attr_accessor :modified

      # Is the instance managed e.g. defined in configuration or set manually.
      # This is used to judge whether to purge an exising resource or not
      attr_accessor :managed

      # Has this instance been newly created.  Used to determine whether to
      # POST or PUT this request via the API
      attr_accessor :created

      # Hash of all attributes and their values.  Keys are symbols
      attr_accessor :attributes

      # Default model contructor
      #
      # Applies to all models.  It may accept a hash of initial values which
      # will set any attributes defined for that class.  It also converts
      # tainted API input so that hash keys are symbols.

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

      # Get the resource title
      #
      # Defaults to the model's name attribute, however things like operating
      # systems don't have unique names, and instead generate a composite title
      # from other attributes.  This is intended to be overriden at the concrete
      # model level if so desired.

      def title
        get(:name)
      end

      # Get an attribute

      def get(attr)
        @attributes[attr]
      end

      # Set an attribute
      #
      # Outside of initization setting an attribute will check to see if there
      # is an existing value and it matches what the intended value is set to
      # be.  If not then the value is updated and the instance flagged as
      # modified and in need of being created or updated.  Inhibits the setting
      # of attributes which are not white-listed.

      def set(attr, new)
        return unless self.class.attributes_get.include?(attr)

        old = get(attr)
        if old.nil? || old != new
          @attributes[attr] = new
          @modified = true
        end
      end

      module ClassMethods
        # Set the white-listed set of attributes that will be set from raw
        # data from the Foreman API

        def attributes(*attr)
          @whitelist ||= []
          @whitelist += attr
        end

        # Get the attribute white-list

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
      #
      # Accepts a noun describing the resource.  This is used to pack
      # POST and PUT requests verbatim, and generate API queries

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
      #
      # Returns a list of all resources found via the API where all attributes are
      # returned by a simple list operation

      module Collector
        module ClassMethods
          def all
            resources = ForemanConfigurator.connection.get(uri, true)
            resources.map do |x|
              if respond_to?(:munge)
                x = munge(x)
              end
              new(x)
            end
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end
      end

      # Deep collector
      #
      # Returns a list of all resources found via the API where all attributes are returned by
      # an API lookup of a specific resource ID and not via a simple list operation.

      module CollectorDeep
        module ClassMethods
          def all
            resources = ForemanConfigurator.connection.get(uri, true)
            resources.map do |resource|
              x = ForemanConfigurator.connection.get(uri(resource['id']))
              if respond_to?(:munge)
                x = munge(x)
              end
              new(x)
            end
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end
      end

      # Emitter
      #
      # Sets or purges a resource via the API.  Dynamically selects POST or PUT
      # based on whether the resource needs to be created or updated.  Resource IDs
      # are updated on the instance as they are created on resource creation.  This
      # facilitates resource caching.

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

        def delete
          ForemanConfigurator.connection.delete(self.class.uri(get('id')))
        end
      end
    end
  end
end
