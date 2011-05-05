Sequel.migration do

  up do
    create_table(:doubles_games) do
      primary_key :id
      Timestamp :created_at
      Integer :winner_score
      Integer :loser_score
      Integer :set_id
      Integer :served_id
      Integer :winner1_id
      Integer :winner2_id
      Integer :loser1_id
      Integer :loser2_id
    end
  end

  down do
    drop_table(:doubles_games)
  end

end
