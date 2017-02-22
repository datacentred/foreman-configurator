module ForemanConfigurator
  module Collector
    def all
      resources = ForemanConfigurator.connection.get(path_get, true)
      resources.map{|x| new(x)}
    end
  end
end
