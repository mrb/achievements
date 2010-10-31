module Achievements
  # Triggering multiple at once
  
  class Engine
    attr_accessor :achievements
    attr_accessor :contexts
    attr_accessor :redis
    
    def initialize(contexts, redis)
      @contexts = contexts
      @redis = redis
      @achievements = {}
      @contexts.collect{|c| @achievements[c] = []}
    end
    
    def bind(context,name,threshold)
      return if !@contexts.include?(context)
      if achievement = Achievement.new(context,name,threshold)
        @achievements[context] << achievement
                
        [threshold].flatten.each do |thresh|
          @redis.sadd "#{context}:#{name}:threshold", thresh.to_s
        end
      end
    end
    
    # The trigger method accepts:
    # context, agent_id, name
    #
    # And returns:
    # context, name, threshold
    def trigger(context, agent_id, name)
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
