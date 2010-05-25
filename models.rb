require 'vendor/ringo/lib/ringo.rb'

REDIS = Ringo.redis

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

  class << self
    def name_key(*args)
      self.key('name', *args)
    end

    alias get_by_id []
    def [](name)
      id = REDIS[self.name_key(name)]
      if id
        return get_by_id(id)
      else
        return self.new(:name => name)
      end
    end
  end

  def initialize(attrs={})
    if attrs[:name]
      self.name = attrs[:name]
      REDIS[Room.name_key(attrs.delete(:name))] = self.id
      env['faye.client'].subscribe "/#{self.name}" do |message|
        self.messages << Message.new(
          :content => message.message,
          :name => message.name
        )
      end
    end
    super
  end

  alias __set_name name=
  def name=(val)
    REDIS.delete[Room.name_key(self.name)] if self.name
    REDIS[Room.name_key(val)] = self.id
    __set_name(val)
  end
end
