Sequel.migration do

  up do
    create_table(:games) do
      primary_key :id
      Timestamp :created_at
      String :winner
      String :loser
      Integer :winner_score
      Integer :loser_score
    end
  end

  down do
    drop_table(:games)
  end

end
