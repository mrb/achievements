# An Abstract, Redis-Backed Achievements Engine
require 'rubygems'
require 'redis'

module AchievementEngine
  # Give the class that includes the AE some nice convenience class
  # methods for instantiating an engine and adding achievements
  def self.included(base)
    base.extend IncludeClassMethods
  end
  
  # Convenience Class Methods for ActiveRecord::Base like User Classes
  class IncludeClassMethods
    
  end
  
  class Achievements
    attr_accessor :redis
    attr_accessor :achievements
    
    def initialize
      @redis ||= Redis.connect
      @achievements = []
    end

    def bind(achievement_hash)
      if achievement = Achievement.new(achievement_hash)
        @achievements << achievement
      end
    end

    def trigger
    
    end
  end

  class Achievement
    attr_accessor :key
    attr_accessor :threshold
  
    def initialize
    
    end
  end

  class Counter
    attr_accessor :context
    attr_accessor :user_id
    attr_accessor :key

    def initialize(context, user_id, key_prefix)
      @key = "#{context}:user:#{user_id}:#{key_prefix}"
    end
  
    def incr
  
    end
  end
end
