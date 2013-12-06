# Client
[![Build Status](https://travis-ci.org/bonzofenix/client.png)](https://travis-ci.org/bonzofenix/client)

Client provides you with metaprogram ruby rest clients generated from yml configurations.

## Installation

Add this line to your application's Gemfile:

    gem 'client'
    
and run `bundle`

## Usage
Client tries to generate res clients at soon as you require the gem.
It will try to find `client.yml` in the main folder of your project:

    /my_project/client.yml
    
The yaml should look something like this:

```yml
    google:
        base_uri: 'http://www.google.com'
    twitter:
        base_uri: 'http://www.twitter.com'
```

This will generate a rest client for you to perform post and gets and return NET/http responses:

```ruby
    require 'client'
    Client::Google.get 'search', query: {q: 'bonzofenix gem client'}
    #This should perform a GET to http://www.google.com/search?q=bonzofenix+gem+client
    
    #Some rest magic too:

    Client::Twitter.list_tweets(user_id: 2) #also try find_
    #This should perform a GET to http://www.twitter.com/tweets?user_id=bonzofenix+gem+client

    Client::Twitter.destroy_tweets(id: 3) #also try remove_ delete_ 
    #This should perform a DELETE to http://www.twitter.com/tweets/3

```

You can also load specific yml files:

```ruby
    require 'client'
    Client.load_clients 'config/twitter.yml', 'config/google.yml'
    Client::Twitter
    # => Client::Twitter
    Client::Google
    # => Client::Google
```

See the spec folder for more examples.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
