set :stage, :production
set :rails_env, 'production'

server ENV.fetch("SRV_PROD"), user: 'ec2-user', roles: %w{app web db}

# auth
set :ssh_options, {
  keys: [File.expand_path(ENV.fetch("SRV_AUTH"))],
  forward_agent: true,
  auth_methods: %w(publickey)
}