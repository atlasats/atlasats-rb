#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'atlasats'
require './util'



### Subscribe for updates when an order book changes ###



# See helper class 'Util' in util.rb
client = Util.logon

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