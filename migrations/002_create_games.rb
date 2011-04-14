Sequel.migration do

  up do
    create_table(:games) do
      primary_key :id
      Timestamp :created_at
      Integer :winner_score
      Integer :loser_score
      foreign_key :winner_id, :players
      foreign_key :loser_id, :players
    end
  end

  down do
    drop_table(:games)
  end

end
