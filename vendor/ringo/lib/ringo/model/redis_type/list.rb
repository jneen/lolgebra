module Ringo
  class RedisList < RedisType
    declare_with :list
    
    def push(val)
      redis.rpush(self.key, @type.set_filter(val))
    end
    alias << push

    def pop
      p @type
      @type.get_filter(redis.rpop(self.key))
    end

    def unshift(val)
      redis.lpush(self.key, @type.set_filter(val))
    end
    alias >> unshift

    def shift
      @type.get_filter(redis.lpop(self.key))
    end

    def [](val)
      if val.is_a? Range
        redis.lrange(self.key, val.first, val.last).map do |s|
          @type.get_filter(s)
        end
      elsif val.is_a? Fixnum
        @type.get_filter(redis.lindex(self.key, val))
      end
    end

    def all
      self[0..-1]
    end
    alias to_a all

    def set(k,v)
      redis.lset(self.key, k, @type.set_filter(v))
    end
    alias []= set

    def count
      redis.llen(self.key).to_i
    end

    def empty?
      self.count == 0
    end

    def method_missing(meth, *args, &blk)
      if Array.public_instance_methods.include? meth
        self.to_a.call(meth, *args, &blk)
      else
        super
      end
    end
  end
end
