module Achievements
  # Counter class is a Redis key factory.
  class Counter
    def self.make(context, agent_id, name)
      @key = "#{context}:agent:#{agent_id}:#{name}"
    end
  end
end
