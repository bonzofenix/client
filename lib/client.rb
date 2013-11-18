require 'client/version'
require 'net/http'
require 'yaml'

class String
  def camelize
    self.split("_").each {|s| s.capitalize! }.join("")
  end
  def camelize!
    self.replace(self.split("_").each {|s| s.capitalize! }.join(""))
  end
  def underscore
    self.scan(/[A-Z][a-z]*/).join("_").downcase
  end
  def underscore!
    self.replace(self.scan(/[A-Z][a-z]*/).join("_").downcase)
  end
end


class Client
  class Base
    class << self
      def endpoint= (endpoint)
        @endpoint = endpoint
      end

      def endpoint
        @endpoint
      end

      def post(resource, params)
        uri = URI("#{endpoint}/#{resource}")
        Net::HTTP.post_form(uri, params)
      end

      def get(resource, params = nil)
        uri = URI("#{endpoint}/#{resource}")
        uri.query = URI.encode_www_form(params) if params
        Net::HTTP.get_response(uri)
      end
    end
  end

  class << self
    def clients
      @clients ||= {}
    end

    def load_clients(path = "#{Dir.pwd}/client.yml")
      begin
        clients.merge! YAML.load_file(path)
      rescue
        warn '''Check that you have an client.env file in your project with
      the following entry.
      gitlab:
        endpoint: http://gitlab.com/api/v3/
      other_server:
        endpoint: other_endpoint.com
        '''
        {}
      end
      generate_clients
    end

    def generate_clients
      clients.each do |name, info|
        Class.new(Base) do
          self.endpoint = info.fetch('endpoint')
        end.tap do |client_class|
          const_set(name.camelize, client_class)
        end
      end
    end
  end

  load_clients
end

