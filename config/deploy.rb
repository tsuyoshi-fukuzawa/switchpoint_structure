lock "~> 3.11.0"

# lib/capistrano/tasks/another.rakeにtaskを定義する。
# migrate
after 'deploy:migrate', 'another:db:migrate'
# rollback
# rollbackは手動で行う
