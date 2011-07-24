require File.expand_path('../spec_helper', __FILE__)

describe "env specific migration" do

  include RailsVersionFilterMethods

  before(:each) do
    clean_database!
  end
 
  it "should only create users and dogs in development" do
    set_env "development"
    run_migrations
    table_exists?("users").should be_true
    table_exists?("accounts").should_not be_true
    table_exists?("dogs").should be_true
    table_exists?("invoices").should_not be_true
  end

  it "should only create accounts and invoices in production" do
    set_env "production"
    run_migrations
    table_exists?("users").should_not be_true
    table_exists?("accounts").should be_true
    table_exists?("dogs").should_not be_true
    table_exists?("invoices").should be_true
  end
  
  it "should set the environments that the migration should run in" do
    CreateInvoices.filtered_environments.should eql(["production","test"])
    CreateUsers.filtered_environments.should eql([:development]) 
    CreateDogs.filtered_environments.should eql([/^dev/])
    CreateAccounts.filtered_environments.should eql([:production])
    
  end

  def table_exists?(table)
    ActiveRecord::Base.connection.execute("select * from sqlite_master where name = '#{table}'").size == 1
  end
  
  def set_env(env)
    if defined? Rails.env
      Rails.env = env
    else
      ENV['RAILS_ENV'] = env
    end
  end
   
  def clean_database!
    models = ["users","accounts","dogs","invoices"]
            
    models.each do |model|
      ActiveRecord::Base.connection.execute "drop table #{model}" rescue nil
    end
  end
   
  def connect
    ENV['DB'] ||= 'development'
    database_yml = File.expand_path('../../database.yml', __FILE__)
    if File.exists?(database_yml)
      active_record_configuration = YAML.load_file(database_yml)[ENV['DB']]
      
      ActiveRecord::Base.establish_connection(active_record_configuration)
      ActiveRecord::Migration.verbose = false
      
    else
      raise "Please create #{database_yml} first to configure your database. Take a look at: #{database_yml}.sample"
    end
  end

  def run_migrations
    if less_than_rails_3_1?
      CreateUsers.migrate :up
      CreateAccounts.migrate :up
      CreateDogs.migrate :up
      CreateInvoices.migrate :up
    else
      CreateUsers.new.migrate :up
      CreateAccounts.new.migrate :up
      CreateDogs.new.migrate :up
      CreateInvoices.new.migrate :up
    end
  end  


end
