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

  # Achivements Interface Class
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
    
    # Accepts a hash with the following format:
    # { :context => context, :categories => [categories] }
    def trigger(action_item_hash)
      
    end

    # Class Methods

    # Finds achievements with context or category.  Both can be either
    # a single instance or an array:
    # {:context => context, :category => category}
    def self.find_achievements(conditions_hash)
      context  = conditions_hash.delete(:context)
      category = conditions_hash.delete(:category)

      if context.present?

      end

      if category.present?

      end
    end
  end
  
  # Achievement, basis of counters
  class Achievement
    attr_accessor :key
    attr_accessor :threshold
  
    def initialize
    
    end
  end
  
  # Formats strings for Redis counter incrs
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
