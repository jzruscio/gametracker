Sequel.migration do

  up do
    create_table(:players) do
      primary_key :id
      String :name
      Timestamp :created_at
      index :name
    end
  end

  down do
    drop_table(:players)
  end

end
