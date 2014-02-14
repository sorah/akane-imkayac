# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'akane-imkayac/version'

Gem::Specification.new do |spec|
  spec.name          = "akane-imkayac"
  spec.version       = AkaneImkayac::VERSION
  spec.authors       = ["Shota Fukumori (sora_h)"]
  spec.email         = ["her@sorah.jp"]
  spec.summary       = %q{imkayac storage plugin for akane | for notification}
  spec.description   = %q{storage plugin for akane | sends matched tweets to im.kayac}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "akane", ">= 0.1.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "webmock", "~> 1.17.3"
  spec.add_development_dependency "rake"
end
