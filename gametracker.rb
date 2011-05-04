#!/usr/bin/ruby

require 'lib/elo'

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sequel'
require 'pg'
require 'activesupport'
require 'haml'
require 'sass'
require 'bcrypt'
require 'rack-flash'
require 'sinatra/redirect_with_flash'

use Rack::Session::Cookie
use Rack::Flash

if ENV['RACK_ENV'] != 'production'
  db = Sequel.connect(ENV['SK_DB_URL'])
else
  db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://my.db')
end

before do
  @players = Player.order(:name).map(:name)
  @current_user = current_user
  unless request.path_info == '/log_in'
    session[:flash] = nil 
  end
  require_auth = ['/new_game', '/new_user', '/update_password']
  if require_auth.index(request.path_info) && !@current_user
    not_logged_in("Please log in")
  end
end

helpers do

  def link_to_player player, current=nil
    if player.capitalize == current
      "#{player}"
    else
      "<a href=\"/user/#{Player.id_from_name(player.capitalize)}\">#{player}</a>"
    end
  end

end

class Game < Sequel::Model
  many_to_one :winner, :class => :Player
  many_to_one :loser, :class => :Player
  many_to_one :gameset
end

class Player < Sequel::Model
  one_to_many :winner_games, :class => :Game, :key => :winner_id
  one_to_many :loser_games, :class => :Game, :key => :loser_id

  def self.id_from_name(name)
    filter(:name => name).first[:id] || nil
  end

  def self.name_from_id(id)
    filter(:id => id).first[:name] || nil
  end

  def self.update_password(user, password)
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    temp = Player.filter(:id => user.id).update(:password_hash => password_hash, :password_salt => password_salt)
  end

  def self.new_player(name, email, department, password)
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    Player.create(
      :name => name.capitalize, 
      :email => email,
      :password_hash => password_hash,
      :password_salt => password_salt,
      :department => department.capitalize,
      :sets_elo => 0,
      :games_elo => 0,
      :created_at => Time.now())
  end

  def self.authenticate(email, password)  
    player = Player.filter(:email => email).first
    if player && !player.password_hash.nil? && (player.password_hash == BCrypt::Engine.hash_secret(password, player.password_salt) )
      player
    else  
      nil  
    end  
  end  

end

class GameSet < Sequel::Model(db[:sets])
  one_to_many :games
end

class GameTracker < Sinatra::Application

  def compute_rankings
    players = Player.all
    ranked = []
    unranked = []
    players.each do |p|
      wins = GameSet.filter(:winner_id => p[:id]).count || 0
      loses = GameSet.filter(:loser_id => p[:id]).count || 0
      if (wins == 0 && loses == 0) 
        percentage = 0
      else 
        percentage = (wins/(wins+loses).to_f).round(3) * 100
      end
      if ((wins + loses) > 2)
        ranked.push({:name => p[:name], :wins => wins, :loses => loses, :percentage => percentage, :department => p[:department], :sets_elo => p[:sets_elo], :games_elo => p[:games_elo]})
      else
        unranked.push({:name => p[:name], :wins => wins, :loses => loses, :percentage => percentage, :department => p[:department], :sets_elo => p[:sets_elo], :games_elo => p[:games_elo]})
      end
    end
     
    ranked = ranked.sort_by{|k| k[:sets_elo]}.reverse
    return ranked, unranked
  end

  def set_winner(winners)
    winners.group_by do |e|
      e
    end.values.max_by(&:size).first
  end

  def save_game(winner, loser, served, score, set)
    points = score.split('-')
    elo = calc_games_elo(winner, loser);
    game = Game.create(
      :winner_id => Player.id_from_name(winner),
      :loser_id => Player.id_from_name(loser),
      :served => Player.id_from_name(served),
      :winner_score => points[0],
      :loser_score => points[1],
      :set_id => set,
      :created_at => Time.now(),
      :winner_elo => elo[:winner],
      :loser_elo => elo[:loser]
    )
  end

  def calc_sets_elo(w, l)
    w_cur_elo = Player.filter(:id => w).first[:sets_elo] || 0
    l_cur_elo = Player.filter(:id => l).first[:sets_elo] || 0
    w_elo = Elo.compute(w_cur_elo, [ [ l_cur_elo, 1] ] )
    l_elo = Elo.compute(l_cur_elo, [ [ w_cur_elo, 0] ] )
    Player.filter(:id => w).update(:sets_elo => w_elo)
    Player.filter(:id => l).update(:sets_elo => l_elo)
    {:winner => w_elo, :loser => l_elo}
  end

  def calc_games_elo(w, l)
    w_id = Player.id_from_name(w)
    l_id = Player.id_from_name(l)
    w_cur_elo = Player.filter(:id => w_id).first[:games_elo] || 0
    l_cur_elo = Player.filter(:id => l_id).first[:games_elo] || 0
    w_elo = Elo.compute(w_cur_elo, [ [ l_cur_elo, 1] ] )
    l_elo = Elo.compute(l_cur_elo, [ [ w_cur_elo, 0] ] )
    Player.filter(:id => w_id).update(:games_elo => w_elo)
    Player.filter(:id => l_id).update(:games_elo => l_elo)
    {:winner => w_elo, :loser => l_elo}
  end

  def sets_with_games(player=nil)
    sets_with_game_count = []
    if player.nil?
      sets = GameSet.order(:created_at.desc).limit(10)
    else
      sets = GameSet.filter(:winner_id => player).or(:loser_id => player).order(:created_at.desc).limit(10)
    end
    sets.each do |set|
      sets_with_game_count.push({
        :winner => Player.name_from_id(set[:winner_id]),
        :loser => Player.name_from_id(set[:loser_id]),
        :winner_elo => set[:winner_elo],
        :loser_elo => set[:loser_elo],
        :num_games => Game.filter(:set_id => set[:id].to_s()).count
      })
    end
    sets_with_game_count
  end

  def not_logged_in(message)
    flash[:notice] = message
    redirect '/log_in'
  end

  def current_user
    Player.filter(:id => session[:player].id).first if session[:player]
  end

  get '/' do
    @games = Game.order(:created_at.desc).limit(10)
    @sets = sets_with_games
    @ranked, @unranked = compute_rankings
    haml :gametracker
  end

  get '/new_game' do
    haml :new_game
  end

  get '/user/:id' do
    @user = Player.filter(:id => params[:id]).first
    @games = Game.filter(:winner_id => params[:id]).or(:loser_id => params[:id]).order(:created_at.desc)
    @sets = sets_with_games(params[:id])
    haml :user
  end

  post '/new_game' do
    winners = []
    ["winner1", "winner2", "winner3"].each do |w|
      if params[w] != ""
        winners << params[w]
      end
    end

    players = [params[:player1], params[:player2]]
    player1 = Player.id_from_name(players[0])
    player2 = Player.id_from_name(players[1])

    set_winner = set_winner([params[:winner1], params[:winner2], params[:winner3]])
    set_winner_id = Player.id_from_name(set_winner)
    set_loser_id = Player.id_from_name( players - [set_winner])
    sets_elo = calc_sets_elo(set_winner_id, set_loser_id)
    set = GameSet.create(:winner_id => set_winner_id, :loser_id => set_loser_id, :created_at => Time.now(), :winner_elo => sets_elo[:winner], :loser_elo => sets_elo[:loser])

    save_game(winners[0], players - [winners[0]], params[:served1], params[:score1], set[:id])
    save_game(winners[1], players - [winners[1]], params[:served2], params[:score2], set[:id])
    if (winners[2])
      save_game(winners[2], players - [winners[2]], params[:served3], params[:score3], set[:id])
    end
    redirect '/'

  end

  get '/new_user' do
    haml :new_user
  end

  post '/new_user' do
    Player.new_player(params[:name], params[:email], params[:department], params[:password])
    redirect '/'
  end

  get '/elo_ratings' do
    p1_cur_elo = Player.filter(:name => params[:p1]).first[:sets_elo]
    p2_cur_elo = Player.filter(:name => params[:p2]).first[:sets_elo]
    p1_wins = Elo.compute(p1_cur_elo, [ [ p2_cur_elo, 1] ] )
    p1_loses = Elo.compute(p1_cur_elo, [ [ p2_cur_elo, 0] ] )
    p2_wins = Elo.compute(p2_cur_elo, [ [ p1_cur_elo, 1] ] )
    p2_loses = Elo.compute(p2_cur_elo, [ [ p1_cur_elo, 0] ] )
    return {:p1_wins => p1_wins, :p1_loses => p1_loses, :p2_wins => p2_wins, :p2_loses => p2_loses, :p1_cur => p1_cur_elo, :p2_cur => p2_cur_elo}.to_json
  end

  get '/log_in' do
    haml :log_in
  end

  post '/log_in' do
    player = Player.authenticate(params[:email], params[:password])
    if player
      session[:player] = player
      flash.now[:notice] = "Signed-in"  
      redirect '/'
    else
      not_logged_in("Invalid email or password")
    end
  end

  get '/log_out' do
    session[:player] = nil
    redirect '/'
  end

  get "/css/:sheet.css" do |sheet|
    sass :"css/#{sheet}"
  end

  get '/update_password' do
    haml :update_password
  end

  post '/update_password' do
    Player.update_password(@current_user, params[:password])
    redirect '/', flash[:notice] => "Password updated"
  end


end
