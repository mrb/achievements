module Achievements
  module AchievementsAgent
    # Convenience methods for instantiating an engine and adding achievements
    def self.included(base)
      base.extend IncludeClassMethods
    end
  
    # Convenience Class Methods for ActiveRecord::Base like User Classes
    module IncludeClassMethods
     

    end

    # Agent instance methods

    # Agent instance level achievement trigger.  Automatically sends
    # agent id along with context and name to the AchievementEngine
    def trigger(context,name)
      Achievements.engine.trigger context, @id, name
    end
  end
end
