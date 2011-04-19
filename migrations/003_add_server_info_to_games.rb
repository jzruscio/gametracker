Sequel.migration do

  up do
    alter_table :games do
      add_column :served, String
    end
  end

  down do
    alter_table :games do
      drop_column :served
    end
  end

end
