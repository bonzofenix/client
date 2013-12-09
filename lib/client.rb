require 'client/version'
require 'net/http'
require 'httparty'
require 'recursive-open-struct'
require 'json'
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

class HTTParty::Response
  def json
    ::JSON.parse(self.body)
  end

  def struct
    case json
      when ::Array
        json.map{|o| ::RecursiveOpenStruct.new o, recurse_over_arrays: true }
      when ::Hash
        ::RecursiveOpenStruct.new json, recurse_over_arrays: true
    end
  end
end

class Client
  class Base
    class << self
      # logger.info "Client::Base performed: #{method} to #{uri.to_s} \
      # params: #{params} got: #{r.inspect} code: #{r.code}"

      def method_missing(m, *args, &block)
        parse_method(m)
        parse_arguments(args)
        perform_action
      end

      private

      def perform_action
        case @action
          when *%w{find list}
            self.get(url, query: @params )
          when *%w{delete remove destroy}
            self.delete(url, body: @params)
          when *%w{post create}
            self.post(url,body: @params)
        end
      end

      def parse_method(name)
        @action, @path = name.to_s.match(/(^[^_]+(?=_))_(.+)/).captures
      end

      def parse_arguments(args)
        @id = args.shift if args.first.is_a?(Integer)
        @params = args.first
      end

      def url
        "/#{@path}".tap do |u|
          u <<  "/#{@id}" if @id
        end
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
        base_uri: http://gitlab.com/api/v3/
      other_server:
        base_uri: other_endpoint.com
        '''
        {}
      end
      generate_clients
    end

    private
    def generate_clients
      clients.each do |name, info|
        Class.new(Base) do
          include HTTParty
          base_uri info.fetch('base_uri')
        end.tap do |client_class|
          const_set(name.camelize, client_class)
        end
      end
    end
  end

  load_clients
end

