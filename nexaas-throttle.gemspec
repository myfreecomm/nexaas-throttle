# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nexaas/throttle/version"

Gem::Specification.new do |spec|
  spec.name          = "nexaas-throttle"
  spec.version       = Nexaas::Throttle::VERSION
  spec.authors       = ["Wanderson Policarpo"]
  spec.email         = ["wanderson.policarpo@myfreecomm.com.br"]

  spec.summary       = %q{A tiny engine to allow throttling and blacklisting requests.}
  spec.description   = %q{A tiny engine to allow throttling and blacklisting requests.}
  spec.homepage      = "https://nexaas.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-rails", "~> 3.5"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "fakeredis"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.6"
  spec.add_development_dependency "simplecov", "~> 0.12"

  spec.add_dependency "rack-attack", "~> 4.4"
  spec.add_dependency "redis-activesupport", "~> 5.0"
end
