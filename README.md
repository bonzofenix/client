# Client

Client provides you with methaprogram ruby rest clients generated from yml configurations.

## Installation

Add this line to your application's Gemfile:

    gem 'client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install client

## Usage
Client tries to generate res clients at soon as you require the gem.
It will try to find `client.yml` in the main folder of your project:

    /my_project/client.yml
    
The yaml should look something like this:

```yml
    google:
        endpoint: 'http://www.google.com'
```

This will generate a rest client for you to perform post and gets and return NET/http responses:

```ruby
    require 'client'
    Client::Google.get 'search', {q: 'bonzofenix gem client'}
    #This should perform a GET to http://www.google.com/search?q=bonzofenix+gem+client
```

You can also load specific yml files:

```ruby
    require 'client'
    Client.load_clients 'config/twitter.yml', 'config/google.yml'
    Client::Google.get 'search', {q: 'bonzofenix gem client'}
    #This should perform a GET to http://www.google.com/search?q=bonzofenix+gem+client
```

See the spec folder for more examples.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
