require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class OperatingSystem
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::CollectorDeep
      include ForemanConfigurator::Model::Backend::Emitter

      attributes :name, :id, :major, :minor, :family, :release_name
      attributes :architecture_ids, :config_template_ids, :medium_ids, :ptable_ids
      parameters :operatingsystem

      # A GET returns expanded references to other resources, for configuration,
      # POST and PUT we need a set of IDs, so perform these replacements
      def self.munge(attrib)
        mappings = {
          'architectures'    => 'architecture_ids',
          'config_templates' => 'config_template_ids',
          'media'            => 'medium_ids',
          'ptables'          => 'ptable_ids',
        }
        mappings.each do |k, v|
          attrib[v] = attrib[k].map{|x| x['id']}.sort if attrib[k]
        end
        attrib
      end

      # Override the instance title with a composite
      def title
        get(:name) + ' ' + get(:major) + '.' + get(:minor)
      end
    end
  end
end
