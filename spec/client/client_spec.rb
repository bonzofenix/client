require 'spec_helper'

describe Client do
  describe 'when there is a config' do
    before do
      stub_request(:any, /.*twitter.*/)
      Client.load_clients(File.expand_path('../fixtures/twitter.yml',
                                           File.dirname(__FILE__)))
      Client.init
    end

    describe '#load_clients' do
      it 'warns when it can fine the file'
    end

    it 'creates a subclass' do
      Client::Twitter.should be
    end

    it 'perform a post' do
      Client::Twitter.post('tweet', {id: '1', text: 'wtf'})
      WebMock.should have_requested(:post, 'http://twitter.com/tweet')
      .with { |req| req.body == 'id=1&text=wtf' }
    end

    it 'perform a get' do
      Client::Twitter.get('tweet')
      WebMock.should have_requested(:get, 'http://twitter.com/tweet')
    end

    it 'perform a get with params' do
      Client::Twitter.get('tweet', {id: 10})
      WebMock.should have_requested(:get, 'http://twitter.com/tweet?id=10')
    end
  end
end
