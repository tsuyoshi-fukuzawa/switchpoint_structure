namespace :ticket do
  desc 'Migrate Ticket Database'
  task :migrate do
    on roles(:db) do
      within release_path do
        execute :bundle, :exec, :rake, "another:db:migrate RAILS_ENV=#{fetch :rails_env}"
      end
      # execute :bundle, :exec, :rake, "another:db:migrate"
      # 
    end
  end

  desc 'Rollback Ticket Database'
  task :rollback do
    on roles(:db) do
      execute :bundle, :exec, :rake, "another:db:rollback"
    end
  end
end
