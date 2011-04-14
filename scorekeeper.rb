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
  db = Sequel.connect(ENV['DATABASE_URL'])
end

class Players < Sequel::Model
end

class Games < Sequel::Model
end

class ScoreKeeper < Sinatra::Application

  get '/' do
    @games = Games.order(:created_at)
    haml :scorekeeper
  end

  get '/new_game' do
    haml :new_game
  end

  post '/new_game' do
    Games.create(:winner => params[:winner],
      :winner_score => params[:winner_score],
      :loser => params[:loser_score],
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
