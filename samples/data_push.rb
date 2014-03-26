#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'atlasats'
require './util'



### Subscribe for updates when an order book changes ###



# Provide the URI of the Atlas server
uri = 'test.atlasats.com'

## API key associated with the account:
# When logged in to the website, see in top-right corner of home page "<your name> -> Settings"
# At bottom-left of the setting page, find the "API Access" section and:
# - click "Enable"
# - retrieve your API key and use below
key = "17ee0d91cc103a0670536ed828e3c14e"

# Instantiating an API client object
client = AtlasClient.new(uri, key)

# Send subscription to 'BTC' book updates
client.subscribe_book_updates "BTC", "USD" do |update|
	bids = []
	ofrs = []
	update["quotes"].each do |q|
		q["side"] == "BUY" ? bids.push(q) : ofrs.push(q)
	end
	system ("clear")
	Util.montage(bids, ofrs)
end

# Send subscription to 'BTC' trade updates
client.subscribe_trades "BTC", "USD" do |trade|
	puts trade.inspect
end

while true
	sleep 60
end