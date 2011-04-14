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
    players = Game.distinct(:winner_id)
    rankings = []
    players.each do |p|
      wins = Game.filter(:winner_id => p.winner_id).count
      loses = Game.filter(:loser_id => p.winner_id).count
      rankings.push({:name => Player.filter(:id => p.winner_id).first[:name], :wins => wins, :loses => loses, :percentage => wins/(wins+loses) * 100})
    end
     
    rankings 
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
    Game.create(
      :winner_id => Player.filter(:name => params[:winner_name]).first[:id],
      :winner_score => params[:winner_score],
      :loser_id => Player.filter(:name => params[:loser_name]).first[:id],
      :loser_score => params[:loser_score],
      :created_at => Time.now())
    redirect '/'
  end

  get '/new_user' do
    haml :new_user
  end

  post '/new_user' do
    Players.create(:name => params[:name], :created_at => Time.now())
    redirect '/'
  end

end
