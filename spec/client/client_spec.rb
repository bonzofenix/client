require 'spec_helper'

describe Client do
  subject(:client) do
    Client::RandomClient
  end

  it 'defaults to client.yml if no file is loaded' do
    client.should be
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

    it 'perform a post' do
      client.post_tweet(id: '1', text: 'wtf')
      WebMock.should have_requested(:post, 'http://twitter.com/tweet')
      .with { |req| req.body == 'id=1&text=wtf' }
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
        client.send("#{action}_tweet", {id: 10})
        WebMock.should have_requested(:get, 'http://twitter.com/tweet?id=10')
      end

      it "perform a get with params and id for #{action}" do
        client.send("#{action}_tweet", 1, {token: 1234})
        WebMock.should have_requested(:get, 'http://twitter.com/tweet/1?token=1234')
      end
    end

    %w{delete remove destroy}.each do |action|
      it "perform a delete with id for #{action}" do
        client.send("#{action}_tweet", 1)
        WebMock.should have_requested(:delete, 'http://twitter.com/tweet/1')
      end

      it "perform a delete with params and id for #{action}" do
        client.send("#{action}_tweet", 1, {token: 1234})
        WebMock.should have_requested(:delete, 'http://twitter.com/tweet/1')
        .with { |req| req.body == 'token=1234' }

      end
    end

  end

  describe 'when working with nested urls' do
    pending 'resolves first level of nested resource' do
      client.groups(1).should be_kind_of(client)
    end
  end



  describe 'when loading config files manually' do
      it 'warns when it can fine the file'
    end
  it 'returns struct'
  it 'returns json'
end
