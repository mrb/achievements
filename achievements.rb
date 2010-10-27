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
  module IncludeClassMethods
    def achievable
      @achievements_engine = Achievements.new
    end

    def bind(achievement_hash)
      @achievements_engine.bind(achievement_hash)
    end
  end

  # Achivements Interface Class
  class Achievements
    attr_accessor :redis
    attr_accessor :achievements
    
    def initialize
      connect if @redis.nil?
      @achievements = []
    end
    
    def connect
      @redis ||= Redis.connect
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

    ## Class Methods

    # Finds achievements with context or category.  Both can be either
    # a single instance or an array:
    # {:context => context, :category => category}
    def self.find_achievements(conditions_hash)
      query = []
      
      context  = conditions_hash.delete(:context)
      category = conditions_hash.delete(:category)    
    end
  end

  # User, lightweight representation of user for convenience
  class User
    attr_accessor :id
    attr_accessor :counters
  end
  
  # Achievement, basis of counters
  class Achievement
    attr_accessor :key
    attr_accessor :threshold
    attr_accessor :categories
    attr_accessor :context
  
    def initialize(achievement_hash)
      @key = achievement_hash.delete(:key)
      @threshold = achievement_hash.delete(:threshold)
      @categories = achievement_hash.delete(:categories)
      @context = achievement_hash.delete(:context)
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
  end
end
