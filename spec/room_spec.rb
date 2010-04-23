describe "creating rooms" do
  before :each do
    Ringo.redis.flushdb
  end

  it "creates them automagically" do
    Room['foo'].should be_a Room
  end
end
