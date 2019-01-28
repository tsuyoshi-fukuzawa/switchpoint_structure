require 'dotenv'
Dotenv.load

set :application, "switchpoint_structure"
set :repo_url, "git@github.com:tsuyoshi-fukuzawa/switchpoint_structure.git"
set :branch, 'master'
set :deploy_to, '/home/ec2-user/www/switchpoint_deploy'

set :default_env, { path: "/home/ec2-user/.rbenv/shims:/home/ec2-user/.rbenv/bin:$PATH" }
set :rbenv_custom_path, '/home/ec2-user/.rbenv/bin/rbenv'
set :rbenv_type, :user
set :rbenv_ruby, '2.5.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all

set :keep_releases, 5
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_files, %w{.env}

set :stage, :production
set :rails_env, 'production'

set :migration_role, :another
set :conditionally_migrate, true

# set :migration_servers, -> { primary(fetch(:migration_role)) }

app_servers = ["ec2-user@#{ENV.fetch('SRV_PROD1')}", "ec2-user@#{ENV.fetch('SRV_PROD2')}"]
role :app, app_servers
role :another, app_servers.first
# role :app, ["ec2-user@#{ENV.fetch('SRV_PROD1')}", "ec2-user@#{ENV.fetch('SRV_PROD2')}"]
# role :db, ["ec2-user@#{ENV.fetch('SRV_PROD1')}"]

# auth
set :ssh_options, {
  keys: [File.expand_path(ENV.fetch("SRV_AUTH"))],
  forward_agent: true,
  auth_methods: %w(publickey)
}

after 'deploy:migrate', 'another:db:migrate'
