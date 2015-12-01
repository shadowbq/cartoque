source 'https://rubygems.org'

# Core framework
gem 'rails', '~> 4.0'
gem 'rake'

# Rails 3's asset pipeline
gem 'json'
gem 'sass-rails', '~> 4.0'
gem 'coffee-rails'
gem 'uglifier'
# JS Runtime
gem 'therubyracer'

# App's gems
gem 'inherited_resources'
gem 'simple_form', '~> 3.0'
gem 'show_for'
gem 'has_scope'
gem 'jquery-rails', '>= 1.0.12'
gem 'pdfkit', '>= 0.5.3'
gem 'wkhtmltopdf-binary'
gem 'storcs', '~> 0.0.3'
gem 'hashie'
gem 'nokogiri'
gem 'draper', '~> 2.0'
#gem 'deface', '= 0.7.2'
gem 'rabl', '>= 0.5.3'
# Mongo / data manipulation
gem 'mongoid', '~> 4'
gem 'bson_ext'
gem 'mongoid-ancestry'
gem 'mongoid_rails_migrations'
gem 'mongoid_alize' #denormalizartion
gem 'mongoid_slug'
# Styles
gem 'bootstrap-sass'
gem 'font-awesome-sass-rails'
gem 'lograge'
# Authentication
gem 'omniauth'
gem 'omniauth-cas', '=1.0.1'
gem 'devise'
gem 'devise-token_authenticatable', '~> 0.4'

gem 'thin'

# Plugins/engines
Dir.glob(File.expand_path("../vendor/plugins/*/Gemfile",__FILE__)).each do |gemfile|
  instance_eval File.read(gemfile)
end

# Debugging tools
gem 'log_buddy'
group :development, :test do
  gem 'quiet_assets'
  gem 'pry'
  gem 'i18n-verify'
end

# Tests
group :test do
  gem 'test-unit'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'spork'
  gem 'guard-spork'
  gem 'growl' if RUBY_PLATFORM.match /darwin/
  gem 'libnotify' if RUBY_PLATFORM.match /linux/
  # listen to file modifications
  gem 'listen'
  gem 'rb-fsevent' if RUBY_PLATFORM.match /darwin/
  gem 'rb-inotify' if RUBY_PLATFORM.match /linux/
  # the cover_me gem is not compatible with rbx and jruby
  # but only need this on one environment...
  # gem 'cover_me', :platforms => :mri_19
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'capybara'
end
