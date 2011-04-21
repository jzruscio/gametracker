Sequel.migration do

  up do
    alter_table :games do
      add_column :set_id, Integer
    end
  end

  down do
    alter_table :games do
      drop_column :set_id
    end
  end

end
