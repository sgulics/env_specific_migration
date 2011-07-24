# $LOAD_PATH << "." unless $LOAD_PATH.include?(".")

begin
  require "rubygems"
  require "bundler"

  if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.5")
    raise RuntimeError, "Your bundler version is too old." +
     "Run `gem install bundler` to upgrade."
  end

  # Set up load paths for all bundled gems
  Bundler.setup
rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems." +
    "Did you run \`bundlee install\`?"
end

Bundler.require

begin 
  require 'active_support/benchmarkable' 
rescue LoadError  
  nil
end
require 'rails/version' 
require "active_record"

ENV['DB'] ||= 'development'
database_yml = File.expand_path('../../database.yml', __FILE__)
if File.exists?(database_yml)
  active_record_configuration = YAML.load_file(database_yml)[ENV['DB']]
  
  ActiveRecord::Base.establish_connection(active_record_configuration)
  ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
  
  # ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  # end  
  
else
  raise "Please create #{database_yml} first to configure your database. Take a look at: #{database_yml}.sample"
end
load File.expand_path('../../lib/env_specific_migration.rb', __FILE__)
load File.expand_path('../migrations.rb',__FILE__)
