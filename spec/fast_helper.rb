# Rspec 3 Deprecation Fixes only
RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
end
