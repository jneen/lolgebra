module Ringo
  class << self
    attr_writer :redis
    def redis(options={})
      @redis ||= Redis.new(options)
    end

    def test!
      self.redis = MockRedis.new
    end
  end
end
