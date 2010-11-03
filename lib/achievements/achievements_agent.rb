module Achievements
  module AchievementsAgent
    # Convenience methods for instantiating an engine and adding achievements
    def self.included(base)
      base.extend IncludeClassMethods
    end
  
    # Convenience Class Methods for ActiveRecord::Base like User Classes
    module IncludeClassMethods
      def engine_class(engine_class)
        @engine_class = engine_class
      end

      def engine
        @engine_class
      end
    end

    # Agent instance methods

    # Agent instance level achievement trigger.  Automatically sends
    # agent id along with context and name to the AchievementEngine
    def achieve(context,name)
      self.class.engine.achieve context, @id, name
    end

    # Determine a user's 'score'
    def score(context=nil,name=nil)
      self.class.engine.score(@id, context, name)
    end
  end
end
