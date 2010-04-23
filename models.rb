require 'vendor/ringo/lib/ringo.rb'

REDIS = Redis.new

class Message < Ringo::Model
  string :content
  string :name

  def to_hash
    {
      :message => self.content,
      :name => self.name
    }
  end
end

class Room < Ringo::Model
  string :name
  list :messages, :of => :references, :to => Message

  def initialize(attrs={})
    if attrs[:name]
      @name = attrs[:name]
      REDIS[self.name_key(attrs.delete(:name))] = self.id
    end
    super
  end

  class << self
    def name_key(*args)
      Room.key('name', *args)
    end

    alias get_by_id []
    def [](name)
      id = REDIS[name_key(name)]
      if id
        return get_by_id(id)
      else
        return self.new(:name => name)
      end
    end
  end

  alias set_name name=
  def name=(val)
    raise "room #{val} already exists" if Room[val]
    REDIS.delete Room.name_key(self.name)
    REDIS[Room.name_key(val)] = self.id
    set_name(val)
  end
end
