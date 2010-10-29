module Achievements
  class Engine
    attr_accessor :achievements
    attr_accessor :contexts
    
    def initialize(contexts)
      @contexts = contexts
      @achievements = {}
      @contexts.collect{|c| @achievements[c] = []}
      @redis = Achievements.redis
    end
    
    def bind(context,name,threshold)
      if achievement = Achievement.new(context,name,threshold)
        @achievements[context] << achievement
        @redis.set "#{context}:#{name}", threshold
      end
    end

    # Increment counter
    # Check threshold
    # Output results
    #
    # context, agent_id, name
    def trigger(context, agent_id, name)
      achieved = []
      # Increment parent counter
      counter = Counter.new(context,agent_id,"parent")
      incr counter
      # Increment child counter
      counter = Counter.new(context,agent_id,name)
      result = incr counter
      # Check Threshold
      if result.to_s >= @redis.get("#{context}:#{name}")
        achieved << [context,name]
        return achieved
      else
        return []
      end
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
