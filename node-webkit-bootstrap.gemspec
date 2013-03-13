Gem::Specification.new do |gem|
  gem.authors       = ["Audiosocket"]
  gem.email         = ["tech@audiosocket.com"]
  gem.description   = "A minimal bootstraping app for node-wekbit."
  gem.summary       = "Set of rake tasks and default templates to develop and build node-webkit application."
  gem.homepage      = "https://github.com/audiosocket/node-webkit-bootstrap"

  gem.files         = `git ls-files`.split "\n"
  gem.name          = "node-webkit-bootstrap"
  gem.require_paths = ["lib"]
  gem.version       = "1.0.0"

  gem.required_ruby_version = ">= 1.9.2"

  gem.add_dependency "curb",    "~>0.8.3"
  gem.add_dependency "rake",    "~>0.9.2.2"
  gem.add_dependency "rubyzip", "~>0.9.9"
end
