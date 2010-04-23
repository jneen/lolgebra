#### config for rackup
require 'sinatra'
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)
require File.join(File.dirname(__FILE__), 'init')
run Sinatra.application
