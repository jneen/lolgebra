require File.expand_path(File.join(
  File.dirname(__FILE__),
  '../vendor/redis-rb/lib/redis'
))

class RedisProxy
  class ConnectionError < StandardError; end

  class << self
    attr_writer :redis
    def redis
      @redis ||= Redis.new
    end

    def [](type)
      REDIS_TYPES[type.to_sym]
    end
  end

  class RedisType
    def redis
      RedisProxy.redis
    end

    def self.letter(l=nil)
      @letter ||= l
    end

    def letter
      self.class.letter
    end

    def self.commands(c=nil)
      @commands ||= c
    end

    def commands
      self.class.commands
    end

    attr_reader :key
    def initialize(key)
      @key = key
    end

    def method_missing(meth, *args)
      if self.commands.include?(meth.to_s)
        self.redis.send(self.letter + meth.to_s, @key, *args)
      else
        super
      end
    rescue Errno::ECONNREFUSED => ex
      raise RedisProxy::ConnectionError, ex.message
    end
  end

  class RedisString < RedisType
    letter ''
    commands [
      'set',
      'get',
      'incr',
      'incrby',
      'decr',
      'decrby',
    ]

    def to_i
      self.get.to_i
    end
  end

  class RedisSet < RedisType
    letter 's'
    commands [
      'add',
      'rem',
      'ismember',
      'members',
      'card',
      'randmember',
    ]

    def <<(val)
      self.add(val)
    end

    def to_a
      self.members
    end

    def count
      self.card
    end

    def include?(val)
      self.ismember(val.to_s)
    end

    def empty?
      self.count == 0
    end

    def rand
      self.randmember
    end
  end

  class RedisZSet < RedisType
    letter 'z'
    commands [
      #TODO
    ]
  end

  class RedisList < RedisType
    letter 'l'
    commands [
      'index',
      'trim',
      'rem',
      'len',
      'set',
    ]

    def method_missing(meth, *args)
      if ['rpush','rpop', 'lpush', 'lpop'].include? meth.to_s
        self.redis.send(meth, @key, *args)
      else
        super
      end
    end

    def push(val)
      self.rpush(val)
    end
    alias << push

    def pop
      self.rpop
    end

    def shift
      self.lpop
    end

    def unshift(val)
      self.lpush(val)
    end
    alias >> unshift

    def count
      self.len
    end

    def empty?
      self.len == 0
    end

    def [](i)
      self.index(i)
    end

    def []=(i, val)
      self.set(i,val)
    end

    def random
      self[rand(self.count)]
    end
  end

  class RedisHash < RedisType
    #not yet implemented in redis
  end

  REDIS_TYPES = {
    :string => RedisString,
    :set => RedisSet,
    :zset => RedisZSet,
    :hash => RedisHash,
    :list => RedisList,
  }

end
