require 'rubygems'
require 'active_support/inflector'

module Ringo
  ROOT = File.expand_path(File.dirname(__FILE__))
  def self.key(*args)
    (['ringo'] + args.map {|a| a.to_s}).join(':')
  end
end

$:.unshift Ringo::ROOT
require File.expand_path(File.join( 
  File.dirname(__FILE__),
  '../vendor/redis-rb/lib/redis.rb'
))
require File.expand_path(File.join( 
  File.dirname(__FILE__),
  '../vendor/mock_redis/lib/mock_redis.rb'
))
require 'ringo/core_ext.rb'
require 'ringo/redis.rb'
require 'redis_proxy.rb'
require 'ringo/model.rb'
$:.shift

class << RedisProxy
  def redis
    Ringo.redis
  end
end
