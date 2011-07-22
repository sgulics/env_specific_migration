class CreateUsers < ActiveRecord::Migration

  run_migration_only_in :development

  if less_than_rails_3_1?
    def self.up
      create_table :users do |t|
        t.string :name
      end
    end

    def self.down
      drop_table :users
    end
  else
    def up
      create_table :users do |t|
        t.string :name
      end
    end

    def down
      drop_table :users
    end
  end

end


class CreateAccounts < ActiveRecord::Migration

  run_migration_only_in :production

  if less_than_rails_3_1?
    def self.up
      create_table :accounts do |table|
        table.string :name
      end
    end

    def self.down
      drop_table :accounts
    end
  else
    def up
      create_table :accounts do |table|
        table.string :name
      end
    end

    def down
      drop_table :accounts
    end
  end
end


class CreateDogs < ActiveRecord::Migration

  run_migration_only_in /^dev/

  if less_than_rails_3_1?
    def self.up
      create_table :dogs do |t|
        t.string :name
      end
    end

    def self.down
      drop_table :dogs
    end
  else
    def up
      create_table :dogs do |t|
        t.string :name
      end
    end

    def down
      drop_table :dogs
    end
  end
end

