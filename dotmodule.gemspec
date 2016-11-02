# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dotmodule/version'

Gem::Specification.new do |spec|
  spec.name          = 'dotmodule'
  spec.version       = DotModule::VERSION
  spec.authors       = ['Cormac Cannon']
  spec.email         = ['cormacc.public@gmail.com']

  spec.summary       = %q{Manage dotfiles in a modular fashion using GNU Stow}
  spec.description   = %q{Wraps GNU stow, using a set of conventions for additions to load path, bash/zsh environment etc.}
  spec.homepage      = 'https://rubygems.org/gems/dotmodule'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^#{spec.bindir}/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor', '~> 0.19.1'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
end
