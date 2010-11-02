module Achievements
  module AchievementsEngine
    def self.engine
      @engine
    end

    def self.included(base)
      base.extend IncludeClassMethods
    end

    module IncludeClassMethods
      # Instantiates the AchievementEngine and sets
      # the contexts, which instantiate context specific counters.  Use
      # only once.
      # 
      # make_engine [:context1,:context2]
      #
      def make_engine(contexts)
        @redis = Achievements.redis
        @engine = Engine.new(@redis)
      end
      
      # Convenience method for accessing the current engine instance directly
      def engine
        @engine
      end
      
      # Convenienve method for accessing redis instance
      def redis
        @redis
      end

      # Binds an achievement with a specific counter threshold. Use as
      # many as you'd like.
      #
      # bind :context, :name, threshold
      #
      def achievement(context, name, threshold)
        make_engine(context) if !@engine
        @engine.achievement(context,name,threshold)
      end
      
      # Alternately, bind an entire array of achievement objects.  To
      # use this, achievements must respond to the context, name, and
      # threshold methods.
      #
      # For example, when using with rails:
      #
      # bind_all Achievement.all
      #
      def achievements(object_array)
        object_array.each do |object|
          make_engine(context) if !@engine
          @engine.achievement object.context, object.name, object.threshold
        end
      end

      # Trigger a bound achievement method.  Since this is a class
      # level method, you must include the agent id along with the
      # method call
      #
      # trigger agent_id, context, name
      #
      def achieve(context, agent_id, name)
        @engine.achieve context, agent_id, name
      end

      def achieves(context_name_array)
        context_name_array.each do |cna|
          Achievements.engine.achieve cna[0], @id, cna[1]
        end
      end
      

    end
  end
end
