# https://qiita.com/dany1468/items/93a36356df695d537a8a

namespace :another do
  task :set_custom_db_config_paths do
    ENV['SCHEMA']                                     = 'db/schema_another.rb'
    Rails.application.config.paths['db']              = ['db']
    Rails.application.config.paths['db/migrate']      = ['db/migrate_another']
    Rails.application.config.paths['db/seeds.rb']     = ['db/seeds_another.rb']
    Rails.application.config.paths['config/database'] = ['config/database_another.yml']
    ActiveRecord::Migrator.migrations_paths           = 'db/migrate_another'
  end

  namespace :db do
    task drop: :set_custom_db_config_paths do
      Rake::Task["db:drop"].invoke
    end

    task create: :set_custom_db_config_paths do
      Rake::Task["db:create"].invoke
    end

    task migrate: :set_custom_db_config_paths do
      Rake::Task["db:migrate"].invoke
    end

    task rollback: :set_custom_db_config_paths do
      Rake::Task["db:rollback"].invoke
    end

    task reset: :set_custom_db_config_paths do
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
    end

    task seed: :set_custom_db_config_paths do
      Rake::Task["db:seed"].invoke
    end

    task version: :set_custom_db_config_paths do
      Rake::Task["db:version"].invoke
    end

    namespace :test do
      task prepare: :set_custom_db_config_paths do
        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
      end
    end
  end
end