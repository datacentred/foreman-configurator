# Resource model base type
#
# All resources have a name which is unique.  Attributes are defined in
# concrete type constructors, which; add the attribute symbol name to an
# array so we can look the names up, initialize the instance variable
# associated with an attributes and create get and set methods.  The latter
# is also responsible for tracking whether an attribute has been altered
# or not.
module ForemanConfigurator
  module Model
    attr_accessor :name
    attr_accessor :modified
    attr_accessor :managed
    attr_accessor :created

    def initialize(name, init={})
      # Set and freeze the name
      @name = name
      @name.freeze
      # Translate initialization data keys to symbols
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
      @@whitelist ||= []

      def attributes(*attr)
        @@whitelist = attr
      end

      def attributes_get
        @@whitelist
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
