require File.dirname(__FILE__) + '/test_helper'

context "AchievementEngine" do
  setup do
    class User
      include AchievementEngine::UserIncludes
      achievable({})
    end

    class Achievement

    end

    class Item

    end
  end
end
