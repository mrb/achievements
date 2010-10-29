$LOAD_PATH.unshift 'lib'
#
# Publishing
#

desc "Push a new version to Gemcutter"
task :publish do
  require 'achievements/version'

  sh "gem build achievements.gemspec"
  sh "gem push achievements-#{Achievements::Version}.gem"
  sh "git tag v#{Achievements::Version}"
  sh "git push origin v#{Achievements::Version}"
  sh "git push origin master"
  sh "git clean -fd"
  
end
