module Achievements
  # Counter class is really a Redis key factory.  Responsibility of
  # communicating with Redis belongs with the engine.
  class Counter
    attr_accessor :context
    attr_accessor :agent_id
    attr_accessor :key

    def initialize(context, agent_id, name)
      @key = "#{context}:agent:#{agent_id}:#{name}"
    end

    def to_s
      @key
    end

  end
end
