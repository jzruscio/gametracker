Sequel.migration do

  up do
    alter_table :players do
      add_column :sets_elo, Integer
      add_column :games_elo, Integer
    end
  end

  down do
    alter_table :players do
      drop_column :sets_elo
      drop_column :games_elo
    end
  end

end
