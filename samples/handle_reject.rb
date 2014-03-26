#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'atlasats'
require './util'



### Place an invalid order and retrieve reject reason ###



# See helper class 'Util' in util.rb
client = Util.logon

## Sending a limit order with bad parameters (asset 'WXYZ' does not exist)
returnValue = client.place_limit_order "WXYZ", "USD", "BUY", 0.01, 1

## Retrieve and display reject reason
# (we use a counter 'i' to prevent endless loops, just in case the connection to server is down)
while true
	info = client.order_info returnValue["oid"]
	if info["status"] == 'PENDING'
		sleep 0.1
	else
		puts 'order ' + returnValue["oid"] + ' is ' + info["status"]
		puts info["reject"] if info.has_key? "reject"
		break
	end
end



