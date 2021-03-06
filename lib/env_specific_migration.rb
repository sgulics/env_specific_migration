module RailsVersionFilterMethods
  
  def rails_3_1_and_up?
    Rails::VERSION::MAJOR > 3 || (Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR >= 1)
  end

  def less_than_rails_3_1?
    Rails::VERSION::MAJOR < 3 || (Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR < 1)
  end
end

#FilteredMigration
module EnvSpecificMigration  


  module SupportMethods

    def migrate_with_filtered_migration(direction)
      if run_migration?
        say "running environment specific migration"
        migrate_without_filtered_migration(direction)
      else
        say "ignoring environment specific migration"
      end
    end

    def run_migration?
      result = false
      env = rails_env
      self.filtered_environments.each do |e|
        case e
        when Regexp
          result = e =~ env.to_s
        when String
          result = e == env.to_s
        when Symbol
          result = e.to_s == env
        end
        break if result    
      end
      result
    end

    def rails_env
      if defined?(Rails.env)
        Rails.env
      else
        ENV["RAILS_ENV"]
      end
    end

  end

  module ClassMethods

    # Will only run a migration if its in the comma delimited list of environment symbols
    def run_migration_only_in(*env)
      extend RailsVersionFilterMethods
      
      # In Rails 3.1, the #migrate method was moved to an instance method. 
      if rails_3_1_and_up?
        include EnvSpecificMigration::SupportMethods
        alias_method_chain :migrate, :filtered_migration
        class_attribute :filtered_environments
      else
        class << self
          include EnvSpecificMigration::SupportMethods
          alias_method_chain :migrate, :filtered_migration 
        end   
        class_inheritable_accessor :filtered_environments
      end
      self.filtered_environments = env
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

end

if defined?(ActiveRecord::Migration)
  ActiveRecord::Migration.send(:include, EnvSpecificMigration)

  class EnvSpecificMigration::LocalOnlyMigration < ActiveRecord::Migration
    run_migration_only_in(:development, :test)
  end
end
