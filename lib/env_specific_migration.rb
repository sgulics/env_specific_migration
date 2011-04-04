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
      unless self.respond_to? :migrate_without_filtered_migration
        extend RailsVersionFilterMethods
        
        class << self
          extend RailsVersionFilterMethods
          def migrate_with_filtered_migration(direction)
            if filtered_environments.include?(Rails.env.to_sym)
              puts "-- running environment specific migration"
              migrate_without_filtered_migration(direction)
            else
              puts "-- ignoring environment specific migration"
            end
          end
          
          # We need the following because Rails 3.1 moves the migrate method to an instance method.
          # There is a delegate that is used to provide for backwards compatibility, however in order
          # to allow the alias_method_chain to work, the method already has to exist.
          rails_3_1_and_up do
            def migrate(name, *args, &block)
              (delegate || superclass.delegate).send(name, *args, &block)
            end
          end

          alias_method_chain :migrate, :filtered_migration
        end
        
        less_than_rails_3_1 { class_inheritable_accessor :filtered_environments }
        rails_3_1_and_up    { class_attribute :filtered_environments }

        self.filtered_environments = env
      end
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
