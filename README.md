# DataCentred Foreman Configuration Synchroniser

## Description

Foreman is a web-based server lifecycle manager.  It discovers subnets and domains,
allows the specification of operating systems, host groups and roles and allows
servers to be automatically provisioned via templated preseed scripts.

Although it does perform some level of revision control and history this is inadequate
for our needs.  Take the example of bootstrapping a staging environment where we
want to have Foreman resources automatically provisioned, this is not supported.

This package allows resources to be specified, in code and then synchronised to the
Foreman server.  This enables full change control to be maintained, manual changes
to be automatically reverted, and new instances to be fully populated and ready to
begin automated provisioning.

## Building

    apt-get -y install gcc make libffi-dev
    gem install fpm
    gem build foreman-configurator.gemspec
    fpm -s gem -t deb \
      --depends ruby-activesupport \
      --gem-package-name-prefix ruby \
      foreman-configurator-x.y.z.gem

