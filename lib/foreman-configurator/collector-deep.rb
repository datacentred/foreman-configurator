module ForemanConfigurator
  module CollectorDeep
    def all
      resources = ForemanConfigurator.connection.get(path_get, true)
      resources.map do |resource|
        new(ForemanConfigurator.connection.get("#{path_get}/#{resource['id']}"))
      end
    end
  end
end
