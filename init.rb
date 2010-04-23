require 'rubygems'
require 'sinatra'
require 'erb'

require 'models'
require 'messages'

get '/' do
  "Hello World!"
end

get '/chat/:room' do
  @room_name = Room.new(:name => params[:name]).name
  @name = params[:name]
  erb :chat
end
