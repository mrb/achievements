# An Abstract Achievements Engine
# Include the gem in a Rails project
# Bind hooks in the User model, is_achiever
# Trigger hooks in other model/controller/view methods

require 'rubygems'
require 'redis'

class Achievements
  attr_accessor :redis
  attr_accessor :achievements

  def initialize
    @redis ||= Redis.connect
    @achievements = []
  end

  def bind(achievement_json)
    @achievements
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

