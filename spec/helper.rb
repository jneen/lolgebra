require 'spec'
require 'rack/test'

module RackTestHelpers
  def app
    Sinatra::Application
  end
end

set :environment, :test
Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include RackTestHelpers
end
