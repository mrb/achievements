module Achievements
  # Thresholds should be a set
  
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
      return if !@contexts.include?(context)
      if achievement = Achievement.new(context,name,threshold)
        @achievements[context] << achievement
                
        [threshold].flatten.each do |thresh|
          @redis.sadd "#{context}:#{name}:threshold", thresh.to_s
        end
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
      counter = Counter.make(context,agent_id,"parent")
      incr counter

      # Increment child counter
      counter = Counter.make(context,agent_id,name)
      result = incr counter

      # Check Threshold
    
      if  @redis.sismember("#{context}:#{name}:threshold", result) == true
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
