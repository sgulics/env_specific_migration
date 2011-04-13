module RailsVersionFilterMethods
  def rails_3_1_and_up
    if Rails::VERSION::MAJOR > 3 || (Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR >= 1)
      yield
    end
  end

  def less_than_rails_3_1
    if Rails::VERSION::MAJOR < 3 || (Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR < 1)
      yield
    end
  end
end

#FilteredMigration
module EnvSpecificMigration  
  module ClassMethods

    # Will only run a migration if its in the comma delimited list of environment symbols
    def run_migration_only_in(*env)
      extend RailsVersionFilterMethods
      
      less_than_rails_3_1 do
        unless self.respond_to? :migrate_without_filtered_migration
          class << self
            def migrate_with_filtered_migration(direction)
              if filtered_environments.include?(Rails.env.to_sym)
                puts "-- running environment specific migration"
                migrate_without_filtered_migration(direction)
              else
                puts "-- ignoring environment specific migration"
              end
            end
            alias_method_chain :migrate, :filtered_migration
          end
          class_inheritable_accessor :filtered_environments
        end
      end
      
      # In Rails 3.1, the #migrate method was moved to an instance method. Additionally, class_inheritable_accessor
      # has been replaced by class_attribute.
      rails_3_1_and_up do
        define_method(:migrate_with_filtered_migration) do |direction|
          if self.class.filtered_environments.include?(Rails.env.to_sym)
            puts "-- running environment specific migration"
            migrate_without_filtered_migration(direction)
          else
            puts "-- ignoring environment specific migration"
          end
        end
        alias_method_chain :migrate, :filtered_migration
        class_attribute :filtered_environments
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
