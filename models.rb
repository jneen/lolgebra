require 'vendor/ringo/lib/ringo.rb'

class Room < Ringo::Model
  string :name
  primary_key :name
end

class User < Ringo::Model
  string :name
  reference :room, :to => :room
end

class Message < Ringo::Model
  string :content
  reference :author, :to => :user
end
