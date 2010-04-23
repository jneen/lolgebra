require 'sinatra'
require '/var/src/lolgebra/current/init'
use Faye::RackAdapter, :mount => '/faye', :timeout => 25
run Sinatra::Application
