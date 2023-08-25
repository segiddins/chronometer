# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'chronometer'
  spec.version       = File.read(File.expand_path('VERSION', __dir__)).strip
  spec.authors       = ['Samuel Giddins']
  spec.email         = ['segiddins@segiddins.me']

  spec.summary       = 'A library that makes generating Chrome trace files for Ruby programs easy.'
  spec.homepage      = 'https://github.com/segiddins'
  spec.license       = 'MIT'

  spec.files         = Dir[File.join(__dir__, '{lib/**/*.rb,exe/*,*.{md,txt},VERSION}')].map { |f| f.gsub(__dir__ + '/', '') }
  spec.bindir        = 'exe'
  spec.executables   = ['chronometer']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency     'claide', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.56.0'

  spec.required_ruby_version = '>= 3.2'
end
