require File.dirname(__FILE__) + '/test_helper'
include Achievements

context "Achievements" do
  setup do
    @redis = Achievements.redis
    @redis.flushall
    
    class User
      attr_accessor :id
      include AgentIncludes
      achievable [:context1, :context2, :context3]
      
      # One achievement, one level
      bind :context1, :one_time, "1"
      
      # Two achievements, one level
      bind :context2, :one_time, "1"
      bind :context2, :three_times, "3"

      # One achievement, multiple levels
      bind :context3, :multiple_levels, ["1","5","10"]

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
    @redis.set "test010203818203802", "1"
    assert_equal @redis.get("test010203818203802"), "1"
  end

  test "context instantiation" do
    assert_equal User.engine.contexts, [:context1,:context2,:context3]
  end

  test "achievement instantiation" do
  
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

   test "three time trigger should return nothing after thresh is crossed" do
    @u.trigger :context2, :three_times
    @u.trigger :context2, :three_times
    @u.trigger :context2, :three_times
    response = @u.trigger :context2, :three_times
    assert_equal response, []
  end

  test "x triggers in context should increment parent counter x times" do
    @u.trigger :context2, :three_times
    @u.trigger :context2, :three_times
    assert_equal @redis.get("context2:agent:1:parent"), "2"
  end
  
  test "binding should create key value pair with name, context, and threshold" do
    assert_equal @redis.smembers("context1:one_time:threshold"), ["1"]
  end
  
  test "multi-threshold achievement should have three threshold counters" do
    assert_equal @redis.smembers("context3:multiple_levels:threshold").sort, ["1","10","5"]
  end

  test "multi-threshold achievement should return achievements in order" do
    results = []

    10.times do
      results << @u.trigger(:context3, :multiple_levels)
    end
    
    assert_equal results, [[[:context3, :multiple_levels]],
              [],
              [],
              [],
              [[:context3, :multiple_levels]],
              [],
              [],
              [],
              [],
              [[:context3, :multiple_levels]]]
  end
end
