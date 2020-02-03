lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcresult/version'

Gem::Specification.new do |spec|
  spec.name          = 'xcresult'
  spec.version       = XCResult::VERSION
  spec.authors       = ['Josh Holtz']
  spec.email         = ['me@joshholtz.com']

  spec.summary       = 'Parses xcresult files'
  spec.description   = 'Parses xcresult files for viewing test summaries and code coverages'
  spec.homepage      = 'https://github.com/fastlane-community/xcresult'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
