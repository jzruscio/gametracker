Sequel.migration do

  up do
    create_table(:doubles_sets) do
      primary_key :id
      Timestamp :created_at
      Integer :winner1_id
      Integer :winner2_id
      Integer :loser1_id
      Integer :loser2_id
    end
  end

  down do
    drop_table(:doubles_sets)
  end

end
