module Ringo
  class RedisSet < RedisType
    def include?(obj)
      redis.sismember(self.key, @type.set_filter(obj))
    end
    alias member? include?
    alias ismember include?

    def add(obj)
      redis.sadd(self.key, @type.set_filter(obj))
    end
    alias << add

    def add?(obj)
      return nil if self.include?(obj)
      self.add(obj)
    end

    def delete(obj)
      redis.srem(self.key, @type.set_filter(obj))
    end
    alias rem delete
    alias remove delete

    def delete?(obj)
      return nil if self.include?(obj)
      self.delete(obj)
    end

    def to_a
      redis.smembers(self.key).map do |e|
        @type.get_filter(e)
      end
    end

    def to_set
      Set.new(self.to_a)
    end

    def intersection(obj)
      if obj.is_a? RedisSet
        redis.sinter(self.key, obj.key)
      else
        super
      end
    end
    alias & intersection

    def union(obj)
      if obj.is_a? RedisSet
        redis.sunion(self.key, obj.key)
      else
        super
      end
    end
    alias | union
    alias + union

    def method_missing(meth, *args, &blk)
      if Set.public_instance_methods.include? meth.to_s
        self.to_set.send(meth, *args, &blk)
      else
        super
      end
    end
  end
end
