require 'ringo'

describe RedisProxy do
  before :all do
    Ringo.redis.flushdb
  end

  it 'proxies strings' do
    str = RedisProxy[:string].new 'redisproxy:string_test'
    str.key.should == 'redisproxy:string_test'
    str.incr.should == 1
    str.to_i.should == 1
    str.incr.should == 2
    str.decr.should == 1
    str.get.should == '1'
    str.incrby(5).should == 6
  end

  it 'proxies sets' do
    set = RedisProxy[:set].new 'redisproxy:set_test'
    set.key.should == 'redisproxy:set_test'
    set.should be_empty
    set.add '34'
    set.count.should == 1
    set.should include 34
    set.add 35
    set.to_a.should == ['34','35']
    set.should_not include 36
  end

  it 'proxies lists' do
    list = RedisProxy[:list].new 'redisproxy:list_test'
    list.key.should == 'redisproxy:list_test'
    list.should be_empty
    lambda { list << 'one' }.should_not raise_error
    list[0].should == 'one'
    list.unshift 'zero'
    list.count.should == 2
    list[1].should == 'one'
    list.shift.should == 'zero'
    list >> 'zero'
    list[0].should == 'zero'
    list.push 'two'
    list.pop.should == 'two'
    list.should_not be_empty
    list.count.should == 2
  end

  after :all do
    Ringo.redis.flushdb
  end
end
