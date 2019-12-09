
require_relative 'lib/async/slack/version'

Gem::Specification.new do |spec|
	spec.name          = "async-slack"
	spec.version       = Async::Slack::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	
	spec.summary       = "Build Slack bots and use real time messaging."
	spec.homepage      = "https://github.com/socketry/async-slack"
	spec.license       = "MIT"
	
	spec.files         = `git ls-files -z`.split("\x0")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]
	
	spec.add_dependency "async-rest", "~> 0.12"
	spec.add_dependency "async-websocket", "~> 0.13"
	
	spec.add_development_dependency "async-rspec"
	
	spec.add_development_dependency "covered"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec", "~> 3.0"
end
