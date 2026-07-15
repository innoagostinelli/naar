source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "sprockets-rails"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "bootsnap", require: false
gem "image_processing", "~> 1.2"
gem "aws-sdk-s3", require: false
gem "ransack"
gem "pagy", "~> 9.4"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootstrap", "~> 5.3"
gem "sassc-rails", "~> 2.1"

group :development, :test do
  gem "sqlite3", ">= 2.1"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"

  # Deploy con Capistrano
  gem "capistrano", "~> 3.19", require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem "capistrano-bundler", "~> 2.1", require: false
  gem "capistrano-rbenv", "~> 2.2", require: false
  gem "capistrano3-puma", "~> 6.0", require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
