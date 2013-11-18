require 'bundler/setup'
require 'webmock/rspec'

Dir.chdir File.expand_path('fixtures', File.dirname(__FILE__))
require 'client'


RSpec.configure do |config|
end

