require ::File.expand_path('../spec_helper.rb', __FILE__)

describe FnordMetric::InboundStream do

  before(:all) do
    @redis = Redis.new
    @redis_wrap = RedisWrap.new(@redis)
    FnordMetric::InboundStream.options(
      :redis_url => "redis://localhost:6379",
      :redis_prefix => "fnordmetric-test",
      :event_queue_ttl => 120
    )
    @inbound_stream = FnordMetric::InboundStream.new(nil)
  end

  describe "pushing new events" do
    it "should add parsable event to the queue" do
      data = %Q{{"_type": "started"}\n}

      lambda {
        @inbound_stream.receive_data data
      }.should change { @redis.llen("fnordmetric-test-queue") }.by +1
    end

    it "should reject non parsable events" do
      broken_data = %Q{{"_type": \n"started"}\n}

      lambda {
        @inbound_stream.receive_data broken_data
      }.should_not change { @redis.llen("fnordmetric-test-queue") }
    end
  end
end

