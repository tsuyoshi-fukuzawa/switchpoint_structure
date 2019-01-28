namespace :another do
  namespace :db do
    desc 'Migrate Another Database'
    task :migrate do
      on roles(:another) do
        within release_path do
          execute :bundle, :exec, :rake, "another:db:migrate RAILS_ENV=#{fetch :rails_env}"
        end
      end
    end

    desc 'Rollback Another Database'
    task :rollback do
      on roles(:another) do
        within release_path do
          execute :bundle, :exec, :rake, "another:db:rollback RAILS_ENV=#{fetch :rails_env}"
        end
      end
    end
  end
end
