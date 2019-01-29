lock "~> 3.11.0"

# switchpointに関連しない定義は、deploy/production.rbに記載している

# lib/capistrano/tasks/another.rakeにtaskを定義する。
# rollbackは手動で行う
after 'deploy:migrate', 'another:db:migrate'

