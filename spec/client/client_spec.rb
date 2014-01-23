require 'spec_helper'

describe Client do
  subject(:client) do
    Client::RandomClient
  end
  before{ stub_const('ENV', {'RACK_ENV' => nil}) }

  it 'defaults to client.yml if no file is loaded' do
    client.should be
  end

  describe 'when RACK_ENV is presence' do
    it 'tries to load config/client_production.yml' do
      stub_const('ENV', {'RACK_ENV' => 'production'})
      Client.load_clients
      Client.loaded_config_files[1].should match(/config\/client_production.yml/)
    end
  end

  describe 'when there is a config' do
    before do
      stub_request(:any, /.*twitter.*/)
      Client.load_clients("#{Dir.pwd}/twitter.yml")
    end

    subject(:client) do
      Client::Twitter
    end

    it 'creates a subclass' do
      client.should be
    end

    it 'returns the endpoint' do
      client.base_uri.should  =='http://twitter.com'
    end
    it 'perform a post' do
      client.post_tweet(body: {id: '1', text: 'wtf'})
      WebMock.should have_requested(:post, 'http://twitter.com/tweet')
      .with { |req| req.body == 'id=1&text=wtf' }
    end

    describe 'when json content type is given ' do
      it 'parse the post body to json' do
      client.post_tweet(body:{id: '1', text: 'wtf'}, content_type: :json)
      WebMock.should have_requested(:post, 'http://twitter.com/tweet')
      .with { |req| req.body == '{"id":"1","text":"wtf"}' }
      end
    end

    it 'perform a get with params' do
      client.get('/tweet', query: {id: 10})
      WebMock.should have_requested(:get, 'http://twitter.com/tweet?id=10')
    end

    it 'perform a get' do
      client.get('/tweet')
      WebMock.should have_requested(:get, 'http://twitter.com/tweet')
    end


    %w{find list}.each do |action|
      it "perform a get with params for #{action}" do
        client.send("#{action}_tweet", query: {id: 10})
        WebMock.should have_requested(:get, 'http://twitter.com/tweet?id=10')
      end

      it "perform a get with params and id for #{action}" do
        client.send("#{action}_tweet", 1, query: {token: 1234})
        WebMock.should have_requested(:get, 'http://twitter.com/tweet/1?token=1234')
      end
    end

    %w{delete remove destroy}.each do |action|
      it "perform a delete with id for #{action}" do
        client.send("#{action}_tweet", 1)
        WebMock.should have_requested(:delete, 'http://twitter.com/tweet/1')
      end

      it "perform a delete with params and id for #{action}" do
        client.send("#{action}_tweet", 1, body: {token: 1234})
        WebMock.should have_requested(:delete, 'http://twitter.com/tweet/1')
        .with { |req| req.body == 'token=1234' }

      end
    end

  end



  describe 'when loading config files manually' do
      it 'warns when it can fine the file'
    end
  it 'returns struct'
  it 'returns json'
end
