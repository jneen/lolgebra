require 'rubygems'
require 'sinatra'
require 'erb'

require 'models'
require 'messages'

ROOT = File.expand_path(File.dirname(__FILE__))
set :views, File.join(ROOT, 'views')
REVISION = begin
  File.read(File.join(ROOT, 'REVISION'))
rescue Errno::ENOENT
  `git rev-parse HEAD`
end

get '/health' do
  "Hello World! I'm running commit #{REVISION}"
end

get '/chat/:room' do
  @room_name = params[:room].downcase
  response.set_cookie 'username',
    @username = params[:name] || request.cookies['username'] || ''
  unless params[:name] or not @username or @username == ''
    redirect "/chat/#{params[:room]}?name=#{@username}"
  else
    erb :chat
  end
end
