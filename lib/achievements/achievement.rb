module Achievements
  
  # Achievement, basis of counters
  class Achievement
    attr_accessor :name
    attr_accessor :threshold
    attr_accessor :context
    
    # A method needs a context, name, and threshold, in that order.
    # 
    def initialize(context, name, threshold)
      @context = context
      @name = name
      @threshold = threshold
    end

    # Convenience to_hash method
    def to_hash
      {:name => @name, :threshold => @threshold, :context => @context}
    end

  end
end
