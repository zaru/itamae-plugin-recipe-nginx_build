# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/plugin/recipe/nginx_build/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae-plugin-recipe-nginx_build"
  spec.version       = Itamae::Plugin::Recipe::NginxBuild::VERSION
  spec.authors       = ["zaru"]
  spec.email         = ["zarutofu@gmail.com"]

  spec.summary       = %q{Itamae plugin to install nginx-build}
  spec.description   = %q{Itamae plugin to install nginx-build}
  spec.homepage      = "https://github.com/zaru/itamae-plugin-recipe-nginx_build"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "itamae", "~> 1"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
