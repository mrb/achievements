require File.dirname(__FILE__) + '/test_helper'

context "Achievements" do
  setup do
    class User
      attr_accessor :id
      include Achievements::AgentIncludes
      achievable [:context1, :context2]

      bind :context1, :one_time, 1
      bind :context2, :three_times, 3

      def initialize(id)
        @id = id
      end
    end

    class Achievement
      attr_accessor :name, :context, :threshold
      include Achievements::AchievementIncludes
    end

    class Item

    end

    @u = User.new(1)
  end

  test "first time trigger should create two counters and increment both" do
    @u.trigger :context1, :one_time
  end
end
