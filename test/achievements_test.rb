require File.dirname(__FILE__) + '/test_helper'
include Achievements

context "Achievements" do
  setup do
    @redis = Achievements.redis
    @redis.flushall
    
    class User
      attr_accessor :id
      include AgentIncludes
      achievable [:context1, :context2]

      bind :context1, :one_time, 1
      bind :context2, :three_times, 3

      def initialize(id)
        @id = id
      end
    end

    class Achievement
      attr_accessor :name, :context, :threshold
      include AchievementIncludes
    end

    class Item

    end
    
    @u = User.new(1)
  end

  test "simple redis test" do
    @redis.set "test010203818203802", 1
    assert_equal @redis.get("test010203818203802"), "1"
  end

  test "context instantiation" do
    assert_equal User.engine.contexts, [:context1,:context2]
  end

  test "achievement instantiation" do
  
  end

  test "binding should create key value pair with name, context, and threshold" do
    assert_equal @redis.get("context1:one_time"), "1"
  end
  
  test "first time trigger should create two counters and increment both" do
    @u.trigger :context1, :one_time
    assert_equal @redis.get("context1:agent:1:parent"), "1"
    assert_equal @redis.get("context1:agent:1:one_time"), "1"
  end

  test "one time trigger should return achievement name as threshold is crossed" do
    response = @u.trigger :context1, :one_time
    assert_equal response, [[:context1,:one_time]]
  end

  test "three time trigger should return achievement names as threshold is crossed" do
    @u.trigger :context2, :three_times
    @u.trigger :context2, :three_times
    response = @u.trigger :context2, :three_times
    assert_equal response, [[:context2, :three_times]]
  end
end
