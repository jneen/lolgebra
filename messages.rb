require 'faye'
use Faye::RackAdapter, :mount => '/faye', :timeout => 25

get '/chat/:room_name/messages' do
  room = Room[params[:room_name]]
  first = params[:start].to_i
  last = (params[:end] || -1).to_i

  # Note that if a client has already subscribed to a channel,
  # resubscribing just overwrites the block originally used to
  # subscribe. (I had originally assumed there'd be multiple
  # subscriptions leading to duplicate messages.)
  # I found this out by looking through the source code.
  # Documentation fail, but Ruby win!
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
