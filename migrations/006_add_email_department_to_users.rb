Sequel.migration do

  up do
    alter_table :players do
      add_column :email, String
      add_column :department, String
    end
  end

  down do
    alter_table :players do
      drop_column :email
      drop_column :department
    end
  end

end
