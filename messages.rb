require 'faye'
use Faye::RackAdapter, :mount => '/faye', :timeout => 25

get '/chat/:room_name/messages' do
  room = Room[params[:room_name]]
  first = params[:start].to_i
  last = (params[:end] || -1).to_i

  return {
    :status => 1,
    :messages => room.messages[first..last].map(&:to_hash),
    :last_id => (last < 0 ? room.messages.count + last : last)
  }.to_json
end

post '/chat/:room_name/messages' do
  if params[:message].strip!.empty?
    return
  end
  env['faye.client'].publish("/#{params[:room_name]}", {
    'message' => params[:message],
    'name' => params[:name]
  })
  room = Room[params[:room_name]]
  message = Message.new(
    :content => params[:message],
    :name => params[:name]
  )
  room.messages << message
end