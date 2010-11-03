module Achievements
  # Triggering multiple at once
  
  class Engine
    attr_accessor :achievements
    attr_accessor :contexts
    attr_accessor :redis
    
    def initialize(redis)
      @contexts = []
      @redis = redis
      @achievements = {}
    end
    
    def achievement(context,name,threshold)
      @contexts << context if !@contexts.include?(context)
      if achievement = Achievement.new(context,name,threshold)
        [threshold].flatten.each do |thresh|
          @redis.sadd "#{context}:#{name}:threshold", thresh.to_s
        end
      end
    end

    def achievements(achievement_array)
      return unless achievement_array.is_a?(Array)
      achievement_array.each do |achievement|
        achievement(achievement.context, achievement.name, achievement.threshold)
      end
    end
    
    # The trigger method accepts:
    # context, agent_id, name
    #
    # And returns:
    # context, name, threshold
    def achieve(context, agent_id, name)
      achieved = []
      
      # Increment parent counter
      counter = Counter.make(context,agent_id,"parent")
      incr counter

      # Increment child counter
      counter = Counter.make(context,agent_id,name)
      result = incr counter

      # Check Threshold
    
      if  @redis.sismember("#{context}:#{name}:threshold", result) == true
        achieved << [context,name, result.to_s]
        return achieved
      else
        return []
      end
      
    end

    def achieves(achievements)
      response = []
      achievements.each do |a|
        response << achieve(a[0],a[1],a[2])
      end
      response
    end

    # incr key
    def incr(counter)
      @redis.incr counter
    end
    
    # decr key
    def decr(counter)
      @redis.decr counter
    end

    def deactiveate(counter)
      @redis.set counter, "ACHIEVED"
    end
    
    ## Class Methods
   
       
  end
end
