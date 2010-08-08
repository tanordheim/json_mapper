require "rake"
require "jeweler"
require "bundler"
require "rake/testtask"

# Gemcutter/Jeweler configuration
# ----------------------------------------------------------------------------
Jeweler::Tasks.new do |gem|
  
  gem.name = "json_mapper"
  gem.summary = "Ruby gem for mapping JSON data structures to Ruby classes"
  gem.email = "tanordheim@gmail.com"
  gem.homepage = "http://github.com/tanordheim/json_mapper"
  gem.authors = [ "Trond Arve Nordheim" ]

  gem.add_bundler_dependencies

end
Jeweler::GemcutterTasks.new

# Test setup
# ----------------------------------------------------------------------------
Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.ruby_opts << "-rubygems"
  test.pattern = "test/**/*_test.rb"
  test.verbose = true
end

# Task setups
# ----------------------------------------------------------------------------
task :test => :check_dependencies
task :default => :test
