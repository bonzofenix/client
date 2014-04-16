require 'bundler/setup'
require 'webmock/rspec'

Dir.chdir File.expand_path('fixtures', File.dirname(__FILE__))
# Cleans the env so that it requires the yml file in the root path.
ENV['RACK_ENV']= nil
require 'client'


RSpec.configure do |config|
end

