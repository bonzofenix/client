require 'client/version'
require 'net/http'
require 'logger'
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
      attr_accessor :endpoint

      def perform(method, resource, params = nil)
        case method
          when :get
            api.get(resource)
          when :post
            api.post(resource, www_params)
          when :delete
            api.delete(resource)
        end.tap do |r|
          logger.info "Client::Base performed: #{method} to #{uri.to_s} \
            params: #{params} got: #{r.inspect} code: #{r.code}"
        end
      end

      def post(resource, params)
        @params = params
        perform(:post, resource)
      end

      def get(resource, params = nil)
        perform(:get ,resource, params)
      end

      def logger
        Client.logger
      end

      def method_missing(m, *args, &block)
        action, path = m.to_s.match(/(^[^_]+(?=_))_(.+)/).captures
        @params = args.first
        case action
          when *%w{find list}
            perform(:get, "/#{path}?#{www_params}")
          when *%w{delete remove destroy}
            perform(:delete, "/#{path}/#{@params}")
        end


      end

      private

      def www_params
        URI.encode_www_form(@params) if @params
      end
      def uri
        URI(endpoint)
      end

      def api
        Net::HTTP.new(uri)
      end
    end
  end

  class << self
    attr_accessor :logger

    def logger
      @logger ||= Logger.new(STDOUT).tap{ |l| l.level = Logger::WARN }
    end

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

