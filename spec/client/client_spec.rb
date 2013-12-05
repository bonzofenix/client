require 'spec_helper'

describe Client do
  it 'defaults to client.yml if no file is loaded' do
    Client::RandomClient.should be
  end

  describe 'when there is a config' do
    before do
      stub_request(:any, /.*twitter.*/)
      Client.load_clients("#{Dir.pwd}/twitter.yml")
    end


    it 'creates a subclass' do
      Client::Twitter.should be
    end

    it 'perform a post' do
      Client::Twitter.post('/tweet', {id: '1', text: 'wtf'})
      WebMock.should have_requested(:post, 'http://twitter.com/tweet')
      .with { |req| req.body == 'id=1&text=wtf' }
    end

    it 'perform a get' do
      Client::Twitter.get('/tweet')
      WebMock.should have_requested(:get, 'http://twitter.com/tweet')
    end

    %w{find list}.each do |action|
      it "perform a get with params for #{action}" do
        Client::Twitter.send("#{action}_tweet", {id: 10})
        WebMock.should have_requested(:get, 'http://twitter.com/tweet?id=10')
      end
    end

    %w{delete remove destroy}.each do |action|
      it "perform a delete with the params for #{action}" do
        Client::Twitter.send("#{action}_tweet", 1)
        WebMock.should have_requested(:delete, 'http://twitter.com/tweet/1')
      end
    end
  end


  describe 'when loading config files manually' do
      it 'warns when it can fine the file'
    end
end
