module Achievements
  class Engine
    attr_accessor :achievements
    attr_accessor :contexts
    attr_accessor :redis

    # Initialize an Achievements Engine by passing a connected redis instance
    def initialize(redis)
      @contexts = []
      @redis = redis
      @achievements = {}
    end

    # Bind one achievement at a time.  Accepts context, name, and threshold.
    def achievement(context,name,threshold)
      @contexts << context if !@contexts.include?(context)
      if achievement = Achievement.new(context,name,threshold)
        [threshold].flatten.each do |thresh|
          @redis.sadd "#{context}:#{name}:threshold", thresh.to_s
        end
      end
    end

    # Bind multiple achievements at a time.  Accepts an array of
    # objects which respond to the context, name, and threshold methods.
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
      
      # Increment user counter
      counter = "agent:#{agent_id}"
      incr counter
      
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

    # Submit multiple achievements to the engine at one time, as an
    # array of arrays.  
    def achieves(achievements)
      response = []
      achievements.each do |a|
        response << achieve(a[0],a[1],a[2]).flatten
      end
      response
    end

    # Increment a given counter
    def incr(counter)
      @redis.incr counter
    end
    
    # Decrement a given counter
    def decr(counter)
      @redis.decr counter
    end

    # Deactivate a counter by setting it to "ACHIEVED," this making it
    # incapable of being incremented or decremented
    def deactiveate(counter)
      @redis.set counter, "ACHIEVED"
    end

    # Retrieve the score of:
    # - specific counter (provide user_id, context, name)
    # - context counter (provide user_id, context)
    # - user counter (provide user_id)
    def score(user_id, context = nil, name = nil)
      scores = []
      scores << @redis.get("agent:#{user_id}")
      scores << @redis.get("#{context}:agent:#{user_id}:parent") unless context.nil?
      scores << @redis.get("#{context}:agent:#{user_id}:#{name}") unless name.nil?
      scores
    end
    
    ## Class Methods
   
  end
end
