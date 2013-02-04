# -*- encoding: utf-8 -*-

require File.expand_path('../lib/spblocks/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "spblocks"
  gem.version       = SPBlocks::VERSION
  gem.summary       = %q{A set of signal processing blocks.}
  gem.description   = %q{Takes the basic signal processing functions found in the splib gem, and contains them in blocks as defined spnet gem.}
  gem.license       = "MIT"
  gem.authors       = ["James Tunnell"]
  gem.email         = "jamestunnell@lavabit.com"
  gem.homepage      = "https://rubygems.org/gems/spblocks"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  
  gem.add_dependency 'spcore'
  gem.add_dependency 'hashmake'
  gem.add_dependency 'spnet'
  gem.add_dependency 'wavefile'

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'yard', '~> 0.8'
end
