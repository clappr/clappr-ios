# -*- encoding: utf-8 -*-
# stub: xcov 1.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "xcov".freeze
  s.version = "1.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Carlos Vidal".freeze]
  s.date = "2019-10-30"
  s.description = "xcov is a friendly visualizer for Xcode's code coverage files".freeze
  s.email = ["nakioparkour@gmail.com".freeze]
  s.executables = ["xcov".freeze]
  s.files = ["bin/xcov".freeze]
  s.homepage = "https://github.com/fastlane-community/xcov".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "xcov is a friendly visualizer for Xcode's code coverage files".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<fastlane>.freeze, [">= 2.82.0", "< 3.0.0"])
    s.add_runtime_dependency(%q<slack-notifier>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<xcodeproj>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<terminal-table>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<multipart-post>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<xcresult>.freeze, ["~> 0.2.0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
  else
    s.add_dependency(%q<fastlane>.freeze, [">= 2.82.0", "< 3.0.0"])
    s.add_dependency(%q<slack-notifier>.freeze, [">= 0"])
    s.add_dependency(%q<xcodeproj>.freeze, [">= 0"])
    s.add_dependency(%q<terminal-table>.freeze, [">= 0"])
    s.add_dependency(%q<multipart-post>.freeze, [">= 0"])
    s.add_dependency(%q<xcresult>.freeze, ["~> 0.2.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
  end
end
