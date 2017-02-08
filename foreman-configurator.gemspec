lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foreman-configurator/version'

Gem::Specification.new do |spec|
  spec.name = 'foreman-configurator'
  spec.version = ForemanConfigurator::VERSION
  spec.authors = ['Simon Murray']
  spec.email = ['spjmurray@yahoo.co.uk']
  spec.summary = %q{DataCentred Foreman Configuration Synchroniser.}
  spec.homepage = 'https://github.com/datacentred/foreman-configurator'
  spec.license = 'MIT'

  files = `git ls-files -z`.split("\x0")
  spec.files = files.grep(%r{^(bin|lib)/})
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
