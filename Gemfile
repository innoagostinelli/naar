source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "sprockets-rails"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "bootsnap", require: false
gem "image_processing", "~> 2.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootstrap", "~> 5.3"
gem "sassc-rails", "~> 2.1"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
