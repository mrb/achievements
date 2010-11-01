require File.dirname(__FILE__) + '/test_helper'

context "Achievement Restructure Test" do
  
  setup do
    Achievements.redis.flushall
    
    class Engine
      include Achievements::AchievementsEngine

      make_engine [:context1, :context2, :context3]
            
      # One achievement, one level
      bind :context1, :one_time, 1
      
      # Two achievements, one level
      bind :context2, :one_time, 1
      bind :context2, :three_times, 3

      # One achievement, multiple levels
      bind :context3, :multiple_levels, [1, 5, 10]
    end

    @engine = Engine.engine
    @redis = Engine.redis
  end

  test "Engine gets assigned appropriate contexts" do
    assert_equal @engine.contexts, [:context1,:context2,:context3]
  end

  test "Contexts get threshold sets" do
    assert_equal @redis.smembers("context1:one_time:threshold"), [1]
    assert_equal @redis.smembers("context2:one_time:threshold"), [1]
    assert_equal @redis.smembers("context2:three_times:threshold"), [3]
    assert_equal @redis.smembers("context3:multiple_levels:threshold").sort, [1,5,10]
  end

  test "Trigger should increment parent (context) and child counter" do
    @engine.trigger(:context1,"1",:one_time)
    assert_equal @redis.get("context1:agent:1:parent"), 1
    assert_equal @redis.get("context1:agent:1:one_time"), 1
  end

  test "Trigger should return crossed threshold" do
    response = @engine.trigger(:context1, 1,:one_time)
    assert_equal [[:context1,:one_time, 1]], response
  end

  test "Trigger with threshold higher than 1" do
    @engine.trigger(:context2, 1, :three_times)
    @engine.trigger(:context2, 1, :three_times)
    result = @engine.trigger(:context2, 1, :three_times)
    assert_equal [[:context2,:three_times, 3]], result
  end

  test "Multiple thresholds" do
    results = []
    10.times do 
      results << @engine.trigger(:context3,1,:multiple_levels)
    end
    assert_equal results, [[[:context3, :multiple_levels, 1]],
                          [],
                          [],
                          [],
                          [[:context3, :multiple_levels, 5]],
                          [],
                          [],
                          [],
                          [],
                          [[:context3, :multiple_levels, 10]]]
  end
end
