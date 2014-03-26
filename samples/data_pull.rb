#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'atlasats'
require './util'



### Send a synchronous request to retrieve market data for a symbol ###



# See helper class 'Util' in util.rb
client = Util.logon

# Get a snapshot of the 'BTC' order book
data = client.book "BTC", "USD" 

# Display the book
puts ''
puts 'Level 2 Order Book:     ' + data["symbol"]
puts 'Last trade:            $' + data["last"].to_s
puts 'Volume (last 24 hours): ' + data["volume"].to_s 
puts ''

# Split into two arrays, bids and offers
bids = []
ofrs = []
data["quotes"].each do |q|
	q["side"] == "BUY" ? bids.push(q) : ofrs.push(q)
end

# Print a Level 2 Montage
Util.montage(bids, ofrs)