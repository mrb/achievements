require File.dirname(__FILE__) + '/test_helper'

context "Achievement Test" do
  
  setup do
    # Flush redis before each test
    Achievements.redis.flushall

    # A sample achievement class.  The instances implement the
    # appropriate methods to be consumed by the engine class, and the
    # class implements a ".all" method to emulate popular ORMs.  This
    # intends to show that it's easy to store your achievements in a
    # database and load them in from there.
    class Achievement
      attr_accessor :context, :name, :threshold

      def self.all
        @all
      end

      def self.all=(a)
        @all ||= []
        @all << a
      end
      
      def initialize(context,name,threshold)
        self.context = context
        @name = name
        @threshold = threshold
        self.class.all = self
      end
    end

    # Make some achievements for the achievements method demonstration
    [[:context4,:five_times,5],[:context5,:two_times,2],[:context6,:once,1]].each do |a|
      Achievement.new(a[0],a[1],a[2])
    end

    # A sample engine class that demonstrates how to use the
    # AchievementsEngine include to instantiate the engine, make
    # achievements, etc.
    class Engine
      include Achievements::AchievementsEngine
      
      # You can either add one achievement at a time with the
      # achievement method which accepts the name of the achievement's
      # context, name, and threshold:
      
      # One achievement, one level
      achievement :context1, :one_time, 1
      
      # Two achievements, one level
      achievement :context2, :one_time, 1
      achievement :context2, :three_times, 3

      # One achievement, multiple levels
      achievement :context3, :multiple_levels, [1, 5, 10]

      # Or you can add multiple achievements at once with the
      # achievements method, which accepts an array.  This array must
      # contain objects which implement id, name, and context
      # methods.  The example below assumes that you have an "all"
      # class method on the Achievement class which returns an array
      # of all instances of that class:
  
      # Passing an array of compliant objects to the achievements method
      achievements Achievement.all
    end

    # A sample agent class that demonstrates how to use the
    # AchievementsAgent include to achieve directly from a user
    # class.  User class must have an id attribute to comply with the API.
    class User
      attr_accessor :id
      include Achievements::AchievementsAgent
          
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
    assert_equal @engine.contexts, [:context1, :context2, :context3,
                                    :context4, :context5, :context6]
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
    assert_equal @redis.get("agent:1"), "10"
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

  test "Members of achievement class should implement methods" do
    Achievement.all.each do |a|
      assert a.respond_to?(:context)
      assert a.respond_to?(:name)
      assert a.respond_to?(:id)
    end
  end

  test "Achievement class should have three members" do
    assert_equal Achievement.all.length, 3
  end

  test "Achieving more than one achievement at a time, no thresholds crossed" do
    assert_equal @engine.achieves([[:context4,1,:five_times],[:context4,1,:five_times]]), [[],[]]
  end

  test "Achieving more than one at a time, threshold crosssed" do
    assert_equal @engine.achieves([[:context1,1,:one_time],[:context2,1,:three_times]]), [[:context1,:one_time,"1"],[]]
  end

  test "Any trigger should increment agent counter" do
    20.times do
      @engine.achieve(:context1,20,:one_time)
    end
    assert_equal @redis.get("agent:20"), "20"
  end

  test "Score retrieval" do
    20.times do
      @user.achieve(:context1,:one_time)
    end
   
    assert_equal @user.score, ["20"]
    assert_equal @user.score(:context1), ["20","20"]
    assert_equal @user.score(:context1,:one_time), ["20","20","20"]
  end
end
