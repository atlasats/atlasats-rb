#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'atlasats'
require './util'



### Place an order, wait til live, and then cancel



# See helper class 'Util' in util.rb
client = Util.logon

## Sending a limit order
# Parameters:
# - asset (examples: "BTC", "LTC Call 700 Apr 2014")
# - currency ("USD")
# - action ("BUY" or "SELL")
# - quantity 
# - price
returnValue = client.place_limit_order "BTC", "USD", "BUY", 0.01, 1

# Store order ID in a variable
oid = returnValue["oid"]

# Wait until the order is open
status = returnValue["status"]
while status == 'PENDING'
	sleep 0.1
	info = client.order_info oid
	status = info["status"]
end

# Print status
puts 'order ' + oid + ' is ' + status

# Check that the order is live and the send a cancel
if status == 'OPEN'
	info = client.cancel_order oid
	puts 'sent cancel request'
	while status == 'OPEN'
		sleep 0.1
		info = client.order_info oid
		status = info["status"]
	end
	# Report result
	puts 'order ' + oid + ' is ' + status
else
	puts 'test failed, order ' + oid + ' is ' + status
end
