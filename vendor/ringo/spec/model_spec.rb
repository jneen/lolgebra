require 'ringo'

describe Ringo::Model, "model" do

  before :all do
    Ringo.redis.flushdb
  end

  it "makes models" do
    class Foo < Ringo::Model
      string :bar
    end

    model = Foo.new

    model.bar.should be_nil
    model.id.should be_a Fixnum

    model
    model.bar = "bar"
    model.bar.should == "bar"

    model_id = model.id
    model_id
    model = Foo[model_id]

    model.should be_a Foo
    model.id.should == model_id
    model.bar.should == "bar"
  end
end
