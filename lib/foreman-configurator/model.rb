module ForemanConfigurator
  module Model
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

      def path(p)
        @path = p
      end

      def path_get
        @path
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
