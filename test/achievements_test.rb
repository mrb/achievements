require File.dirname(__FILE__) + '/test_helper'

context "Achievement Restructure Test" do
  
  setup do
    # Flush redis before each test
    Achievements.redis.flushall

    # A sample engine class that demonstrates how to use the
    # AchievementsEngine include to instantiate the engine, make
    # achievements, etc.
    class Engine
      include Achievements::AchievementsEngine

      # One achievement, one level
      achievement :context1, :one_time, 1
      
      # Two achievements, one level
      achievement :context2, :one_time, 1
      achievement :context2, :three_times, 3

      # One achievement, multiple levels
      achievement :context3, :multiple_levels, [1, 5, 10]
    end

    # A sample agent class that demonstrates how to use the
    # AchievementsAgent include to achieve directly from a user
    # class.  User class must have an id attribute to comply with the API.
    class User
      attr_accessor :id
      include Achievements::AchievementsAgent
      engine_class Engine
      
      def initialize(id)
        @id = id
      end
    end

    # Make a new user with an ID different from the one used in most tests
    @user = User.new(10)

    # For testing purposes, access the engine and redis directly
    @engine = Engine.engine
    @redis = Engine.redis
  end

  test "Engine gets assigned appropriate contexts" do
    assert_equal @engine.contexts, [:context1,:context2,:context3]
  end

  test "Contexts get threshold sets" do
    assert_equal @redis.smembers("context1:one_time:threshold"), ["1"]
    assert_equal @redis.smembers("context2:one_time:threshold"), ["1"]
    assert_equal @redis.smembers("context2:three_times:threshold"), ["3"]
    assert_equal @redis.smembers("context3:multiple_levels:threshold").sort, ["1","10","5"]
  end

  test "Trigger should increment parent (context) and child counter" do
    @engine.achieve(:context1,1,:one_time)
    assert_equal @redis.get("context1:agent:1:parent"), "1"
    assert_equal @redis.get("context1:agent:1:one_time"), "1"
  end

  test "Trigger should return crossed threshold" do
    response = @engine.achieve(:context1, 1,:one_time)
    assert_equal [[:context1,:one_time, "1"]], response
  end

  test "Trigger with threshold higher than 1" do
    @engine.achieve(:context2, 1, :three_times)
    @engine.achieve(:context2, 1, :three_times)
    result = @engine.achieve(:context2, 1, :three_times)
    assert_equal [[:context2,:three_times, "3"]], result
  end

  test "Multiple thresholds" do
    results = []
    10.times do 
      results << @engine.achieve(:context3,1,:multiple_levels)
    end
    assert_equal results, [[[:context3, :multiple_levels, "1"]], [], [], [], [[:context3, :multiple_levels, "5"]], [], [], [], [], [[:context3, :multiple_levels, "10"]]]
  end

  test "Achieving from the agent class" do
    response = @user.achieve(:context1,:one_time)
    assert_equal response, [[:context1,:one_time,"1"]]
  end

  test "Achieving after threshold returns empty from agent and engine class" do
    @user.achieve(:context1,:one_time)
    assert_equal @user.achieve(:context1,:one_time), []
    @engine.achieve(:context1,1,:one_time)
    assert_equal @engine.achieve(:context1,1,:one_time),[]
  end
end
