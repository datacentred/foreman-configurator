require 'foreman-configurator/model'

module ForemanConfigurator
  module Models
    class Subnet
      include ForemanConfigurator::Model::Attributes
      include ForemanConfigurator::Model::Backend::Common
      include ForemanConfigurator::Model::Backend::Collector
      include ForemanConfigurator::Model::Backend::Emitter

      # Required attributes
      attributes :name, :id, :network, :mask
      # Optional network services
      attributes :gateway, :dns_primary, :dns_secondary
      # IPAM options
      attributes :ipam, :from, :to
      # Smart proxy options
      attributes :domain_ids, :dhcp_id, :tftp_id, :dns_id
      # How to boot the machine
      attributes :boot_mode
      parameters :subnet
    end
  end
end
