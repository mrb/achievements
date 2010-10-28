require File.dirname(__FILE__) + '/test_helper'

context "AchievementEngine" do
  setup do
    class User
      attr_accessor :id
      include Achievements::UserIncludes
      achievable [:context1, :context2]

      bind :context1, :one_time, 1
      bind :context2, :three_times, 3

      def initialize(id)
        @id = id
      end
    end

    class Achievement

    end

    class Item

    end

    @u = User.new(1)
  end

  test "should create one " do
    @u.trigger :context1, :one_time
  end
end
