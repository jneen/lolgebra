require 'faye'
use Faye::RackAdapter, :mount => '/faye', :timeout => 25

get '/chat/:room/messages' do
  room = Room[params[:room]]
  first = params[:start].to_i
  last = (params[:end] || -1).to_i

  return {
    :status => 1,
    :messages => room.messages[first..last].map(&:to_hash),
    :last_id => (last < 0 ? room.messages.count + last : last)
  }.to_json
end
