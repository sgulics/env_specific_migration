#FilteredMigration
module EnvSpecificMigration
  
  module ClassMethods


    # Will only run a migration if its in the comma delimited list of environment symbols
    def run_migration_only_in(*env)

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



