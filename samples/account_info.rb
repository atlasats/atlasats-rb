#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'atlasats'
require './util'



### Get account information from the server ###



# See helper class 'Util' in util.rb
client = Util.logon

# Retrieve info relative to the account who's key we're using
info = client.account_info()

# Simple fields
currency = info["currency"]
accounttype = info["type"]
puts accounttype + ' account has ' + info["buyingpower"].to_s + ' ' + currency + ' in buying power'

# Orders
done = 0
open = 0
info["orders"].each do |oid|
	# Retrieve info and count
	ord = client.order_info(oid)
	ord["status"] == 'OPEN' ? open += 1 : done += 1
end

puts 'We have ' + open.to_s + ' open order(s) and ' + done.to_s + ' canceled/executed order(s)'

# Positions
puts 'We are currently:'
info["positions"].each do |pos|
	pnl = pos["realizedpl"] + pos["unrealizedpl"]
	puts "- " + (pos["size"] > 0 ? 'long ' : 'short ') + pos["item"] + ' and ' + (pnl > 0 ? 'making' : 'losing') + ' money'
end