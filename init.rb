require 'rubygems'
require 'sinatra'
require 'erb'

require 'models'
require 'messages'

ROOT = File.expand_path(File.dirname(__FILE__))
REVISION = begin
  `cat #{File.join(ROOT, 'REVISION')}`
rescue Errno::ENOENT
  `git rev-parse HEAD`
end

get '/health' do
  "Hello World! I'm running commit #{REVISION}"
end

get '/chat/:room' do
  @room_name = Room.new(:name => params[:name]).name
  @name = params[:name]
  erb :chat
end
