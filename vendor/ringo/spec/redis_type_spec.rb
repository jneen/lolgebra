require 'ringo'

describe "Ringo::Set" do
  before :each do
    pending "implementation"
    Ringo.redis.flushdb
    class Foo < Ringo::Model
      set :bar, :of => :strings
    end

    @foo = Foo.new

  end

  it "starts out empty" do
    pending "implementation"
    @foo.bar.should be_empty
    @foo.bar.to_a.should == []
    @foo.bar.size.should == 0
    @foo.should_not include "odelay"

    Foo[@foo.id].bar.to_a.should == []
    Foo[@foo.id].bar.size.should == 0
    Foo[@foo.id].should_not include "odelay"
  end

  it "can add an element" do
    pending "implementation"
    @foo.bar.add "odelay"

    @foo.bar.to_a.should == ["odelay"]
    @foo.bar.size.should == 1
    @foo.bar.should include "odelay"
    @foo.bar.should_not include "omgzorz"

    Foo[@foo.id].bar.to_set.should == Set["odelay"]
    Foo[@foo.id].bar.size.should == 1
    Foo[@foo.id].bar.should include "odelay"
    Foo[@foo.id].bar.should_not include "omgzorz"
  end

  it "is idempotent for a single element" do
    pending "implementation"
    5.times { @foo.bar.add "odelay" }

    @foo.bar.to_a.should == ["odelay"]
    @foo.bar.size.should == 1
  end

  it "can add many elements" do
    pending "implementation"
    (1..10).each do |i|
      @foo.bar.add "odelay#{i}"
    end

    @foo.bar.to_set.should == Set[1,2,3,4,5,6,7,8,9,10]
    @foo.bar.size.should == 10
  end

  it "can grab a random member" do
    pending "implementation"
    (1..10).each do |i|
      @foo.bar.add "odelay#{i}"
    end

    10.times do
      r = @foo.bar.rand

      r.should be <= 10
      r.should be >= 1
    end
  end

  it "can handle custom types" do
    pending "implementation"
    class MyType < Ringo::Type
      declare_with :my_type
      def get_filter(val)
        # convert to its set of letters
        Set.new(val.split(//))
      end

      def set_filter(set)
        set.sort.join
      end
    end

    a_set = Set.new("abcdefg".split(//))

    class Foo < Ringo::Model
      set :baz, :of => :my_types
    end

    @foo.baz.should be_empty
    @foo.baz.add a_set
    @foo.baz.should_not be_empty
    @foo.baz.rand.should be_a Set
    @foo.baz.rand.size.should == 6
  end
end
