require 'bundler/setup'
require 'webmock/rspec'

Dir.chdir File.expand_path('fixtures', File.dirname(__FILE__))
puts 'HOLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',ENV['RACK_ENV']
require 'client'


RSpec.configure do |config|
end

