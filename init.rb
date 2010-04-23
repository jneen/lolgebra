require 'rubygems'
require 'sinatra'
require 'erb'

require 'models'
require 'messages'

get '/' do
  "Hello World!"
end

get '/chat/:room' do
  erb :chat
end
