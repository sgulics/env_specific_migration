source "http://rubygems.org"

# Specify your gem's dependencies in env_specific_migration.gemspec
gemspec
rails_version = ENV['RAILS_VERSION']
if rails_version
  puts "Using #{rails_version}"
  gem 'rails', rails_version
else
  puts "Using Current Rails"
  gem 'rails'
end
gem 'rspec'
gem 'sqlite3'

