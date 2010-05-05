require 'rubygems'
require 'sinatra'
require 'erb'

require 'models'
require 'messages'

ROOT = File.expand_path(File.dirname(__FILE__))
set :views, File.join(ROOT, "views")
REVISION = begin
  File.read(File.join(ROOT, 'REVISION'))
rescue Errno::ENOENT
  `git rev-parse HEAD`
end

get '/health' do
  "Hello World! I'm running commit #{REVISION}"
end

get '/chat/:room' do
  @room = Room[params[:room]]
  @username = params[:name] || "Anonymous"
  erb :chat
end
