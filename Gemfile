source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

#
# Default
#
gem 'rails', '~> 5.1.6', '>= 5.1.6.1'
# gem 'sqlite3'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#
# add
#

# Env
gem 'dotenv-rails'

# MySQL
gem 'mysql2', '>= 0.4.6', '< 0.5'

# View
gem 'slim'

# TEST
group :test do
  gem 'rspec'                  # テストツール
  gem 'rspec-rails'            # RailsでRspecが使える
  gem 'factory_bot_rails'     # テストデータの生成
  gem 'faker'                  # テストデータの生成
  gem 'database_cleaner'       # テスト実行後にDBをクリア
  gem 'timecop'                # テスト時に時間を固定できる
  gem 'spring-commands-rspec'  # spring経由でrspecを実行する
  gem 'launchy'
end

# Switching database connection between readonly one and writable one.
gem 'switch_point'

# Logger for database connections
gem 'arproxy'

# Deploy
group :development do
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano3-puma'
end


