Sequel.migration do

  up do
    alter_table :games do
      add_column :set, String
    end
  end

  down do
    alter_table :games do
      drop_column :set
    end
  end

end
