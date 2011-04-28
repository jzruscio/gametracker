require 'gametracker'
task :environment
task :merb_env

task :calc_sets_elo_rankings do

  sets = GameSet.order(:created_at)
  sets.each do |set|
    winner = set[:winner_id] 
    w_elo = Player.filter(:id => winner).first[:sets_elo].to_i || 0
    loser = set[:loser_id]
    l_elo = Player.filter(:id => loser).first[:sets_elo].to_i || 0
    w_nelo = Elo.compute(w_elo, [[l_elo, 1]]).to_i
    l_nelo = Elo.compute(l_elo, [[w_elo, 0]]).to_i
    GameSet.filter(:id => set[:id]).update(:winner_elo => w_nelo, :loser_elo => l_nelo)
    Player.filter(:id => winner).update(:sets_elo => w_nelo)
    Player.filter(:id => loser).update(:sets_elo => l_nelo)
  end

end

task :calc_games_elo_rankings do

  games = Game.order(:created_at)
  games.each do |game|
    winner = game[:winner_id] 
    w_elo = Player.filter(:id => winner).first[:games_elo].to_i || 0
    loser = game[:loser_id]
    l_elo = Player.filter(:id => loser).first[:games_elo].to_i || 0
    w_nelo = Elo.compute(w_elo, [[l_elo, 1]]).to_i
    l_nelo = Elo.compute(l_elo, [[w_elo, 0]]).to_i
    Game.filter(:id => game[:id]).update(:winner_elo => w_nelo, :loser_elo => l_nelo)
    Player.filter(:id => winner).update(:games_elo => w_nelo)
    Player.filter(:id => loser).update(:games_elo => l_nelo)
  end

end
