require 'faye'
use Faye::RackAdapter, :mount => '/faye', :timeout => 25

get '/rooms/:room_name/message' do
  room = Room[params[:room_name]]
  first = params[:start].to_i
  last = (params[:end] || -1).to_i

  return {
    :status => 1,
    :messages => room.messages[first..last].map(&:to_hash)
  }.to_json
end

post '/rooms/:room_name/message' do
  env['faye.client'].publish(
    "/#{params[:room]}",
    'message' => params[:message]
  )
  room = Room[params[:room_name]]
  message = Message.new(
    :content => params[:message],
    :name => params[:name]
  )
end
