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
  room_name = params[:room].downcase
  @room = Room[room_name]

  # Note that if a client has already subscribed to a channel,
  # resubscribing just overwrites the block originally used to
  # subscribe. (I had originally assumed there'd be multiple
  # subscriptions leading to duplicate messages.)
  # I found this out by looking through the source code.
  # Documentation fail, but Ruby win!
  env['faye.client'].subscribe "/#{room_name}" do |message|
    @room.messages << Message.new(
      :content => message["message"],
      :name => message["name"]
    )
  end

  @username = params[:name] || "Anonymous"
  erb :chat
end
