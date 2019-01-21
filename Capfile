require "capistrano/setup"
require "capistrano/deploy"

# for Git
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# for bundle install/migration
require 'capistrano/bundler'
require 'capistrano/rails/migrations'

# for puma restart
require 'capistrano/puma'
install_plugin Capistrano::Puma

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
