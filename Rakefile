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

task :calc_doubles_sets_elo_rankings do
  sets = DoublesSet.order(:created_at)
  sets.each do |set|
    winner = set[:winner_team_id]
    w_elo = DoublesTeam.filter(:id => winner).first[:sets_elo].to_i || 0 
    loser = set[:loser_team_id]
    l_elo = DoublesTeam.filter(:id => loser).first[:sets_elo].to_i || 0 
    w_nelo = Elo.compute(w_elo, [[l_elo, 1]]).to_i
    l_nelo = Elo.compute(l_elo, [[w_elo, 0]]).to_i
    set[:winner_elo] = w_nelo
    set[:loser_elo] = l_nelo
    set.save
    DoublesTeam.filter(:id => winner).update(:sets_elo => w_nelo)
    DoublesTeam.filter(:id => loser).update(:sets_elo => l_nelo)
  end
end

task :order_doubles_teams_sets do
  sets = DoublesSet.order(:created_at)
  sets.each do |set|
    puts "BEF: #{set[:winner1_id]} & #{set[:winner2_id]} vs #{set[:loser1_id]} & #{set[:loser2_id]}"
    p1 = set[:winner1_id]
    p2 = set[:winner2_id]
    p3 = set[:loser1_id]
    p4 = set[:loser2_id]
    if (p2 < p1) 
      set[:winner1_id] = p2
      set[:winner2_id] = p1
    end
    if (p4 < p3) 
      set[:loser1_id] = p4
      set[:loser2_id] = p3
    end
    set.save
    puts "AFT: #{set[:winner1_id]} & #{set[:winner2_id]} vs #{set[:loser1_id]} & #{set[:loser2_id]}"
  end
end

task :order_doubles_teams_games do
  games = DoublesGame.order(:created_at)
  games.each do |game|
    puts "BEF: #{game[:winner1_id]} & #{game[:winner2_id]} vs #{game[:loser1_id]} & #{game[:loser2_id]}"
    p1 = game[:winner1_id]
    p2 = game[:winner2_id]
    p3 = game[:loser1_id]
    p4 = game[:loser2_id]
    if (p2 < p1) 
      game[:winner1_id] = p2
      game[:winner2_id] = p1
    end
    if (p4 < p3) 
      game[:loser1_id] = p4
      game[:loser2_id] = p3
    end
    game.save
    puts "AFT: #{game[:winner1_id]} & #{game[:winner2_id]} vs #{game[:loser1_id]} & #{game[:loser2_id]}"
  end
end

task :populate_doubles_teams_sets do
  sets = DoublesSet.order(:created_at)
  sets.each do |set|
    team1 = [set[:winner1_id], set[:winner2_id]]
    team2 = [set[:loser1_id], set[:loser2_id]]
    dt1 = DoublesTeam.filter(:player1 => team1[0]).and(:player2 => team1[1])
    dt2 = DoublesTeam.filter(:player1 => team2[0]).and(:player2 => team2[1])
    if ( dt1.empty?)
      DoublesTeam.create(:player1 => team1[0], :player2 => team1[1], :created_at => Time.now())
    else
      set[:winner_team_id] = dt1.first[:id]
    end
    if (dt2.empty?)
      DoublesTeam.create(:player1 => team2[0], :player2 => team2[1], :created_at => Time.now())
    else
      set[:loser_team_id] = dt2.first[:id]
    end
    set.save
  end
end

task :populate_doubles_teams_games do
  games = DoublesGame.order(:created_at)
  games.each do |game|
    team1 = [game[:winner1_id], game[:winner2_id]]
    team2 = [game[:loser1_id], game[:loser2_id]]
    dt1 = DoublesTeam.filter(:player1 => team1[0]).and(:player2 => team1[1])
    dt2 = DoublesTeam.filter(:player1 => team2[0]).and(:player2 => team2[1])
    if ( dt1.empty?)
      DoublesTeam.create(:player1 => team1[0], :player2 => team1[1], :created_at => Time.now())
    else
      game[:winner_team_id] = dt1.first[:id]
    end
    if (dt2.empty?)
      DoublesTeam.create(:player1 => team2[0], :player2 => team2[1], :created_at => Time.now())
    else
      game[:loser_team_id] = dt2.first[:id]
    end
    game.save
  end
end
