require 'ringo'

describe Ringo::Type do
  before :all do
    Ringo.redis.flushdb
  end

  it "supports references" do
    class Foo < Ringo::Model
      string :bar
    end

    class Baz < Ringo::Model
      reference :bong, :to => :foo
    end

    foo = Foo.new
    baz = Baz.new
    
    baz.bong.should be_nil
    baz.bong = foo
    Baz[baz.id].bong.should == foo

    lambda do
      baz.bong = 3
    end.should raise_error(Ringo::Reference::Error)

    Baz[baz.id].bong.should == foo
  end
end
