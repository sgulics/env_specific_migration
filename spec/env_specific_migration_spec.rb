require File.expand_path('../spec_helper', __FILE__)

describe "env specific migration" do

  include RailsVersionFilterMethods

  before(:each) do
    clean_database!
  end
 
  it "should only create users and dogs in development" do
    Rails.env = "development"
    run_migrations
    check_table("users").size.should eql(1) 
    check_table("accounts").size.should eql(0) 
    check_table("dogs").size.should eql(1) 
  end

  it "should only create accounts in production" do
    Rails.env = "production"
    run_migrations
    check_table("users").size.should eql(0) 
    check_table("accounts").size.should eql(1) 
    check_table("dogs").size.should eql(0) 
  end

  def check_table(table)
    ActiveRecord::Base.connection.execute("select * from sqlite_master where name = '#{table}'")
  end
   
  def clean_database!
    models = ["users","accounts","dogs"]
            
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
    else
      CreateUsers.new.migrate :up
      CreateAccounts.new.migrate :up
      CreateDogs.new.migrate :up
    end
  end  


end
