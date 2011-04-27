#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sequel'
require 'pg'
require 'activesupport'
require 'haml'
require 'sass'

if ENV['RACK_ENV'] != 'production'
  db = Sequel.connect(ENV['SK_DB_URL'])
else
  db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://my.db')
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

end

class GameSet < Sequel::Model(db[:sets])
  one_to_many :games
end

class GameTracker < Sinatra::Application

  def compute_rankings
    players = Player.all
    rankings = []
    players.each do |p|
      wins = GameSet.filter(:winner_id => p[:id]).count || 0
      loses = GameSet.filter(:loser_id => p[:id]).count || 0
      if (wins == 0 && loses == 0) 
        percentage = 0
      else 
        percentage = (wins/(wins+loses).to_f).round(3) * 100
      end
      rankings.push({:name => p[:name], :wins => wins, :loses => loses, :percentage => percentage, :department => p[:department]})
    end
     
    rankings.sort_by{|k| k[:percentage]*(k[:wins] + k[:loses])}.reverse
  end

  def create_new_user(name)
    Player.create(:name => name, :created_at => Time.now())
  end

  def set_winner(winners)
    winners.group_by do |e|
      e
    end.values.max_by(&:size).first
  end

  def save_game(winner, loser, served, score, set)
    points = score.split('-')
    game = Game.create(
      :winner_id => Player.id_from_name(winner),
      :loser_id => Player.id_from_name(loser),
      :served => Player.id_from_name(served),
      :winner_score => points[0],
      :loser_score => points[1],
      :set_id => set,
      :created_at => Time.now()
    )
  end

  get '/' do
    @games = Game.order(:created_at.desc).limit(10)
    @sets = GameSet.order(:created_at.desc).limit(5)
    @rankings = compute_rankings
    haml :gametracker
  end

  get '/new_game' do
    @players = Player.order(:name).map(:name)
    haml :new_game
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
    set = GameSet.create(:winner_id => set_winner_id, :loser_id => set_loser_id, :created_at => Time.now())

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
    Player.create(
      :name => params[:name], 
      :email => params[:email],
      :department => params[:department],
      :created_at => Time.now())
    redirect '/'
  end

  get "/css/:sheet.css" do |sheet|
    sass :"css/#{sheet}"
  end


end
