module Achievements
  # Achievement, basis of counters
  class Achievement
    attr_accessor :name
    attr_accessor :threshold
    attr_accessor :context
  
    def initialize(context, name, threshold)
      @name = name
      @threshold = threshold
      @context = context
    end

    def to_hash
      {:name => @name, :threshold => @threshold, :context => @context}
    end

  end
end
