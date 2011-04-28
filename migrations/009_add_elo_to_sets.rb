Sequel.migration do

  up do
    alter_table :sets do
      add_column :winner_elo, Integer
      add_column :loser_elo, Integer
    end
  end

  down do
    alter_table :sets do
      drop_column :winner_elo
      drop_column :loser_elo
    end
  end

end
