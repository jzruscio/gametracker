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
end

class Player < Sequel::Model
  one_to_many :winner_games, :class => :Game, :key => :winner_id
  one_to_many :loser_games, :class => :Game, :key => :loser_id
end

class ScoreKeeper < Sinatra::Application

  def compute_rankings
    players = Player.all
    rankings = []
    players.each do |p|
      wins = Game.filter(:winner_id => p[:id]).count
      loses = Game.filter(:loser_id => p[:id]).count
      rankings.push({:name => p[:name], :wins => wins, :loses => loses, :percentage => (wins/(wins+loses).to_f).round(3) * 100})
    end
     
    rankings.sort_by{|k| k[:percentage]}.reverse
  end

  def create_new_user(name)
    Player.create(:name => name, :created_at => Time.now())
  end

  def player_id_from_name(name)
    player = Player.filter(:name => name)
    if !player.empty?
      return player.first[:id]
    else
      return nil
    end
  end

  get '/' do
    @games = Game.order(:created_at.desc).limit(5)
    @rankings = compute_rankings
    haml :scorekeeper
  end

  get '/new_game' do
    haml :new_game
  end

  post '/new_game' do
    winner_id = player_id_from_name(params[:winner_name])
    if winner_id == nil
      create_new_user(params[:winner_name])
      winner_id = player_id_from_name(params[:winner_name])
    end
    loser_id = player_id_from_name(params[:loser_name])
    if loser_id == nil
      create_new_user(params[:loser_name])
      loser_id = player_id_from_name(params[:loser_name])
    end
    Game.create(
      :winner_id => winner_id,
      :winner_score => params[:winner_score],
      :loser_id => loser_id,
      :loser_score => params[:loser_score],
      :created_at => Time.now())
    redirect '/'
  end

  get '/new_user' do
    haml :new_user
  end

  post '/new_user' do
    create_new_user(params[:name])
    redirect '/'
  end

end
