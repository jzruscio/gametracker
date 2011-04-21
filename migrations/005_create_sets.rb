Sequel.migration do

  up do
    create_table(:sets) do
      primary_key :id
      Timestamp :created_at
      foreign_key :winner_id, :players
      foreign_key :loser_id, :players
    end
  end

  down do
    drop_table(:sets)
  end

end
