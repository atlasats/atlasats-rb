#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'atlasats'




### Provide a few function used in the samples ###



class Util

	def self.logon
		# Provide the URI of the Atlas server
		uri = 'test.atlasats.com'

		## API key associated with the account:
		# When logged in to the website, see in top-right corner of home page "<your name> -> Settings"
		# At bottom-left of the setting page, find the "API Access" section and:
		# - click "Enable"
		# - retrieve your API key and use below
		key = "17ee0d91cc103a0670536ed828e3c14e"

		# Instantiate and return an API client object
		AtlasClient.new(uri, key)
	end

	def self.montage(bids, ofrs)
		# Console Montage
		puts "qty".rjust(10) + "bid".rjust(8) + "ask".	rjust(8) + "qty".rjust(10)

		# Loop through level 2 data
		for i in 0..[bids.length, ofrs.length].max
			if i < bids.length
				bidsize = "%0.4f" % [bids[i]["size"]]
				bidprice = "%0.2f" % [bids[i]["price"]]
			else
				bidsize = ''
				bidprice = ''
			end
			if i < ofrs.length
				asksize = "%0.4f" % [ofrs[i]["size"]]
				askprice = "%0.2f" % [ofrs[i]["price"]]
			else
				asksize = ''
				askprice = ''
			end
			puts bidsize.rjust(10) + bidprice.rjust(8) + askprice.rjust(8) + asksize.rjust(10)
		end
	end
end
