require 'faye'
use Faye::RackAdapter, :mount => '/faye', :timeout => 25

get '/chat/:room_name/messages' do
  room = Room[params[:room_name]]
  first = params[:start].to_i
  last = (params[:end] || -1).to_i

  # I'm surprised subscribing multiple times doesn't cause duplicate
  # messages, you'd think the block would get called as many times as
  # subscribed. I mean what if I decided at two different times to
  # subscribe two different blocks to the same channel?
  env['faye.client'].subscribe "/#{params[:room_name]}" do |message|
    room.messages << Message.new(
      :content => message["message"],
      :name => message["name"]
    )
  end

  return {
    :status => 1,
    :messages => room.messages[first..last].map(&:to_hash),
    :last_id => (last < 0 ? room.messages.count + last : last)
  }.to_json
end
