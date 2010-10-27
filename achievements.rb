# An Abstract, Redis-Backed Achievements Engine
require 'rubygems'
require 'redis'

module AchievementEngine
  module UserIncludes
    # Convenience methods for instantiating an engine and adding achievements
    def self.included(base)
      base.extend IncludeClassMethods
    end
  
    # Convenience Class Methods for ActiveRecord::Base like User Classes
    module IncludeClassMethods
      # Instantiates the AchievementEngine and sets
      # the contexts, which instantiate context specific counters.  Use
      # only once.
      # 
      # achieveable {:contexts => [:context1,:context2]}
      #
      def achievable
        @achievements_engine = Achievements.new
      end

      # Binds an achievement with a specific counter threshold. Use as
      # many as you'd like.
      #
      # bind :context, :name, threshold
      #
      def bind(context, name, threshold)
        @achievements_engine.bind(achievement_hash)
      end

      # Alternately, bind an entire array of achievement objects.  To
      # use this, achievements must respond to the context, name, and
      # threshold methods.
      #
      # For example, when using with rails:
      #
      # bind_all Achievement.all
      #
      def bind_all(object_array)
        object_array.each do |object|
          bind object.context, object.name, object.threshold
        end
      end

      # Trigger a bound achievement method.  Since this is a class
      # level method, you must include the user id along with the
      # method call
      #
      # trigger user_id, context, name
      #
      def trigger(user_id, context, name)
        
      end
    end

    # User instance methods

    # User instance level achievement trigger.  Automatically sends
    # user id along with context and name to the AchievementEngine
    def trigger(context,name)
      
    end
  end
  
  module AchievementIncludes
    # Convenience methods
    def self.included(base)
      base.extend IncludeClassMethods
    end

    module IncludeClassMethods
      # Update the threshold for the AchievementEngine achievement
      # that matches context, achievement, and sets threshold to new_threshold
      def update_threshold(context, achievement, new_threshold)
        # find achievement and update threshold
      end 
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
