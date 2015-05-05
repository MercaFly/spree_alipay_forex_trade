spree_alipay_forex_trade
===================

It is a wrapper for https://github.com/chloerei/alipay gem, using the https://github.com/spree/spree_gateway.

Notice that the Alipay only allow CNY(or RMB) payments. Therefore, your site should support CNY currency.

Installation
===================

1. Add this extension to your Gemfile with this line:

```ruby
gem 'spree_alipay_forex_trade', github: 'formrausch/spree_alipay_forex_trade'
```

2. Install the gem using Bundler:

```
bundle install
```


3  Copy & run migrations

```
bundle exec rails g spree_alipay_forex_trade:install
```

4. Restart your server

If your server was running, restart it so that it can process properly.


Usage
===================

1. Use it as a normal Spree:Gateway 

** Forex trade does autocapture. If you have to show a confirm page to the user
before you redirect to Alipay you have to use /alipay/passthrough_forex_trade

Add the AlipayXXX _(e.g. AlipayPartnerTrade) in Spree backend like normal payment. You need to input the _pid, _key, and _senderemail

2. Use it as a alipay button

```
```

** Notice that Refund flow is not implemented yet **

Contributing
===================

1. Supports Alipay ForexTrade thanks to https://github.com/chloerei/alipay
2. Bug report or pull request are welcome.
3. Make a pull request

Fork it

Create your feature branch (git checkout -b my-new-feature)

Commit your changes (git commit -am 'Add some feature')

Push to the branch (git push origin my-new-feature)

Create new Pull Request

Please write unit test with your code if necessary.
