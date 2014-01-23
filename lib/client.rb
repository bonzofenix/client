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
        set_content_type
        perform_action
      end

      private

      def set_content_type
          if @opts && @opts.delete(:content_type) == :json
            @opts[:headers] = { 'Content-Type' => 'application/json' }
            @opts[:body] = @opts[:body].to_json
          end
      end

      def perform_action
        case @action
          when *%w{find list}
            self.get(url,  @opts)
          when *%w{delete remove destroy}
            self.delete(url, @opts)
          when *%w{post create}
            self.post(url, @opts)
        end
      end


      def parse_method(name)
        @action, @path = name.to_s.match(/(^[^_]+(?=_))_(.+)/).captures
      end

      def parse_arguments(args)
        @id = args.shift if args.first.is_a?(Integer)
        @opts = args.first || {}
      end

      def url
        "/#{@path}".tap do |u|
          u <<  "/#{@id}" if @id
        end
      end
    end

  end

  class << self
    attr_accessor :logger, :loaded_config_files

    def logger
      @logger ||= Logger.new(STDOUT).tap{ |l| l.level = Logger::WARN }
    end

    def clients
      @clients ||= {}
    end
    def loaded_config_files
      @loaded_config_files ||= []
    end
    def load_clients(path = "#{Dir.pwd}/client.yml")
      begin
        clients.merge! YAML.load_file(path)
        loaded_config_files << path
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
    def default_config_path
      puts ENV.inspect
      if ENV['RACK_ENV']
      "#{Dir.pwd}/client_#{ENV['RACK_ENV']}.yml"
    else
      "#{Dir.pwd}/client.yml"
    end
  end

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

