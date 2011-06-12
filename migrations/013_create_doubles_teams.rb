Sequel.migration do

  up do
    create_table(:doubles_teams) do
      primary_key :id
      Integer :player1
      Integer :player2
      Integer :sets_elo
      Timestamp :created_at
    end
  end

  down do
    drop_table(:doubles_teams)
  end

end
