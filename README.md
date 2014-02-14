# akane-imkayac - storage plugin for akane that post matched tweet to im.kayac.com

Storage plugin gem for [akane](https://github.com/sorah/akane), that posts matched tweets to im.kayac.com for notification.

## Installation

Add this line to your application's Gemfile:

    gem 'akane-imkayac'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install akane-imkayac

## Usage

In your akane configuration yaml:

```
storages:
  - imkayac:
      user: <im kayac user name>
#     password: <your password (optional)>
#     secret: <your secret key (optional)>
#     handler: <handler erb template>
#     message: <message erb template>
      keywords:
        - keyword to notify 1
        - keyword to notify 2
        - ...
      excludes:
        - keyword to exclude 1
        - keyword to exclude 2
        - ...
```

I set `'tweetbot:///status/<%= tweet.id %>'` to handler for Tweetbot.

`handler` and `message` params are evaluated as ERB. Variable `account` and `tweet` (`Twitter::Tweet`) is available.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/akane-imkayac/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
