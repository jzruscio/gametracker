Sequel.migration do

  up do
    alter_table :players do
      add_column :password_hash, String
      add_column :password_salt, String
    end
  end

  down do
    alter_table :players do
      drop_column :password_hash
      drop_column :password_salt
    end
  end

end
