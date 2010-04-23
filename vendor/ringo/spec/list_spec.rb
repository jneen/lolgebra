require 'ringo'

describe "A Ringo List" do
  before :each do
    Ringo.redis.flushdb
    class Foo < Ringo::Model
      list :bar, :of => :integers
    end
    @foo = Foo.new
    @ref_foo = Foo[@foo.id]
  end

  it "starts out empty" do
    @foo.bar.count.should == 0
    @foo.bar.should be_empty
    @foo.bar.all.should == []
  end

  it "pushes, pops, shifts, unshifts" do
    @foo.bar << 6
    @foo.bar << 7
    @foo.bar << 8
    @ref_foo.bar.pop.should == 8
    @foo.bar.pop.should == 7
    @foo.bar.unshift 5
    @ref_foo.bar.unshift 4
    @foo.bar.unshift 3
    @foo.bar.shift.should == 3
    @ref_foo.bar.shift.should == 4
    @foo.bar.pop.should == 6
    @ref_foo.bar.all.should == [5]
  end

  it "looks up by index" do
    (0..10).each do |i|
      @foo.bar << i
    end
    (0..10).each do |i|
      @foo.bar[i].should == i
    end
  end

  it "slices" do
    (0..10).each do |i|
      @foo.bar << i
    end

    @foo.bar.to_a.should == [0,1,2,3,4,5,6,7,8,9,10]
    @foo.bar[0..5].should == [0,1,2,3,4,5]
    @foo.bar[5..-1].should == [5,6,7,8,9,10]
    @foo.bar[7..-2].should == [7,8,9]
  end

  it "passes on options" do
    class Baz < Ringo::Model
      list :bing, :of => :references, :to => Foo
    end

    baz = Baz.new
    baz.bing << @foo
    baz.bing << @foo
    baz.bing.count.should == 2
    baz.bing.all.should == [@foo, @foo]
  end
end
