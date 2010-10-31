# An Abstract, Redis-Backed Achievements Engine
require 'redis'

require 'achievements/achievement'
require 'achievements/achievements_achievement'
require 'achievements/achievements_agent'
require 'achievements/achievements_engine'
require 'achievements/agent'
require 'achievements/counter'
require 'achievements/engine'
require 'achievements/version'

module Achievements
  def self.redis
    @redis || @redis = Redis.connect
  end
end
