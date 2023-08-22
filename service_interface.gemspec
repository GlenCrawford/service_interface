lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_interface/version'

Gem::Specification.new do |spec|
  spec.name          = 'service_interface'
  spec.version       = ServiceInterface::VERSION
  spec.authors       = ['Glen Crawford']

  spec.summary       = 'Ruby module to provide a strict, boilerplate interface for service classes.'
  spec.homepage      = 'https://github.com/GlenCrawford/service_interface'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |file| file.match(%r{^(spec)/}) }
  end

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 4'

  spec.add_development_dependency 'activesupport', '>= 4'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
