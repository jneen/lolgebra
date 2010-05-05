describe "posting messages" do
  before :each do
    Ringo.redis.flushdb
  end

  it "can create messages" do
    Message.new(:content => "foo", :name => "bar").should be_a Message
  end

  it "can post messages" do
    (0..10).each do |i|
      post '/chat/foo/messages', {
        :message => "hello ##{i}",
        :name => "Jim-Bob"
      }
    end
    message = Room['foo'].messages.pop
    message.should be_a Message
    message.content.should == "hello #10"
    message.name.should == "Jim-Bob"
  end
end

describe "interacting with messages" do
  before :each do
    Ringo.redis.flushdb
    (0..10).each do |i|
      post '/chat/foo/messages', {
        :message => "hello ##{i}",
        :user => "Jim-Bob"
      }
    end
  end

  it "gets messages" do
    get '/chat/foo/messages', {
      :start => -10
    }
    m = JSON[last_response.body]
    m["status"].should == 1
    m["messages"].should be_a Array
    m["messages"].count.should == 10
  end
end
