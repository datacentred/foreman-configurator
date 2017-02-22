require 'yaml'

module ForemanConfigurator
  class Config

    def initialize(path)
      @config = YAML.load(File.open(path))
    end

    def [](key)
      @config[key]
    end

  end
end
