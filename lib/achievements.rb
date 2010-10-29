# An Abstract, Redis-Backed Achievements Engine
require 'redis'

require 'achievements/achievement'
require 'achievements/achievement_includes'
require 'achievements/agent'
require 'achievements/agent_includes'
require 'achievements/counter'
require 'achievements/engine'
require 'achievements/version'

module Achievements
  extend self
  def redis
    @redis || @redis = Redis.connect
  end

end
