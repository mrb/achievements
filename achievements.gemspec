$LOAD_PATH.unshift 'lib'
require 'achievements/version'

Gem::Specification.new do |s|
  s.name              = "achievements"
  s.version           = Achievements::Version
  
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Achievements adds Redis-backed achievments"
  s.homepage          = "http://github.com/mrb/achievements"
  s.email             = "michaelrbernstein@gmail.com"
  s.authors           = [ "Michael R. Bernstein" ]

  s.files             = %w( README.markdown Rakefile LICENSE HISTORY.markdown )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("test/**/*")
  s.files            += Dir.glob("tasks/**/*")
  # s.executables       = [ "achievements", "achievements-web" ]

  s.extra_rdoc_files  = [ "LICENSE", "README.markdown" ]
  s.rdoc_options      = ["--charset=UTF-8"]

  s.add_dependency "redis", "~> 2.1.1"
  
  s.description = <<description
    Achievements is an abstract, Redis-backed, counter based achievements engine
    designed to be included in Model classes in web applications.

    Achievements lets you track and persist user actions with a simple bind and
    trigger design pattern.
description
end
