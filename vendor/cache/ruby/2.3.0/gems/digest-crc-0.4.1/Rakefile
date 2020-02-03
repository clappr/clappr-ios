require 'rubygems'
require 'rake'

begin
  gem 'rubygems-tasks', '~> 0.1'
  require 'rubygems/tasks'

  Gem::Tasks.new
rescue LoadError => e
  warn e.message
  warn "Run `gem install rubygems-tasks` to install 'rubygems/tasks'."
end

begin
  gem 'rspec', '~> 2.4'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new
rescue LoadError => e
  task :spec do
    puts e.message
  end
end
task :test => :spec
task :default => :spec

begin
  gem 'yard', '~> 0.8'
  gem 'redcarpet'
  gem 'github-markup'
  require 'yard'
  require 'redcarpet'
  require 'github-markup'

  YARD::Rake::YardocTask.new
rescue LoadError => e
  task :yard do
    puts e.message
  end
end
