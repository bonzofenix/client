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
      def method_missing(m, *args, &block)
        MetaRequest.new(self , m, args).run
      end
    end



    class MetaRequest
      include HTTParty

      def initialize(base_klass, method, args)
        @base_klass = base_klass
        @method = method
        @args = args
      end

      def run
        parse_method
        parse_arguments
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
            @base_klass.get(url,  @opts)
          when *%w{delete remove destroy}
            @base_klass.delete(url, @opts)
          when *%w{post create}
            @base_klass.post(url, @opts)
        end
      end

      def parse_method
        @action, @path = @method.to_s.match(/(^[^_]+(?=_))_(.+)/).captures
      end

      def parse_arguments
        @id = @args.shift if @args.first.is_a?(Integer)
        @opts = @args.first || {}
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
    def load_clients(path = default_config_path)
      begin
        clients.merge! YAML.load_file(path)
        loaded_config_files << path
      rescue
        warn """Check that you have an file in:  \n\t
        #{path}

that respects the following format:  \n\t
      example:
        base_uri: http://example.com/api/v3/
        """
        {}
      end
      generate_clients
    end

    private
    def default_config_path
      if ENV['RACK_ENV']
      "#{Dir.pwd}/config/client_#{ENV['RACK_ENV']}.yml"
    else
      "#{Dir.pwd}/client.yml"
    end
  end

    def generate_clients
      clients.each do |name, info|
        Class.new(Base) do
          include HTTParty
          self.base_uri info.fetch('base_uri')
        end.tap do |client_class|
          const_set(name.camelize, client_class)
        end
      end
    end
  end

  load_clients
end

