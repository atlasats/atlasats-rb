require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'httparty'
require 'faye'
require 'json'

class AtlasClient
	include HTTParty
	
	def initialize(buri, apikey)
		@baseuri = buri
		@options = { :headers => { "Authorization" => "Token token=\"#{apikey}\"" }, :base_uri => HTTParty.normalize_base_uri(@baseuri) }
	end
	
	def with_auth(body=nil, &block)
		r = block.call(body.nil? ? @options : @options.merge(:body => body))
		r.parsed_response
	end
	
	def place_market_order(side, quantity)
		with_auth :side => side, :quantity => quantity, :type => "market" do |options|
			self.class.post("/api/v1/orders", options)
		end
	end
	
	def place_limit_order(item, currency, side, quantity, price)
		with_auth :item => convert(item), :currency => currency, :side => side, :quantity => quantity, :type => "limit", :price => price do |options|
			self.class.post("/api/v1/orders", options)
		end
	end
	
	def order_info(orderid)
		with_auth nil do |options|
			self.class.get("/api/v1/orders/#{orderid}", options)
		end
	end
	
	def cancel_order(orderid)
		with_auth nil do |options|
			self.class.delete("/api/v1/orders/#{orderid}", options)
		end
	end
	
	# account
	def account_info()
		with_auth nil do |options|
			self.class.get('/api/v1/account', options)
		end
	end
	
	# market data
	def subscribe_quotes(&block)
		Thread.new do
			EM.run {
				client = Faye::Client.new("https://#{@baseuri}:4000/api")
				client.subscribe("/quotes") do |msg|
					block.call(msg)
				end
			}
		end
	end
	
	def subscribe_trades(&block)
		Thread.new do
			EM.run {
				client = Faye::Client.new("https://#{@baseuri}:4000/api")
				client.subscribe("/trades") do |msg|
					begin
						pmsg = JSON.parse(msg)
						block.call(msg)
					rescue Exception
						block.call({ :error => "Unable to parse message", :raw => msg })
					end
				end
			}
		end
	end
	
	def subscribe_book_updates(item, currency, &block)
		Thread.new do
			EM.run {
				client = Faye::Client.new("https://#{@baseuri}:4000/api")
				client.subscribe("/market/#{item}/#{currency}") do |msg|
					pmsg = nil
					begin
						pmsg = JSON.parse(msg)
						block.call(pmsg)
					rescue Exception
						block.call({ :error => "Unable to parse message", :raw => msg })
					end
				end
			}
		end
	end

	private

	## parse this: 			BTC Call 700 Mar 2014
	# and generate this: 	BTC 20140331C 700.000
	# (for option symbols)
	def convert(symbol)
		tokens = symbol.split(' ')
		if tokens.length == 5
			undly = tokens[0]
			type = tokens[1][0]
			strike = format("%.3f", tokens[2].to_f)
			exp = (Date.strptime(tokens[3] + ' ' + tokens[4],"%b %Y") >> 1).prev_day
			expstr = exp.year.to_s + exp.month.to_s.rjust(2, '0') + exp.day.to_s.rjust(2, '0')
			return undly + ' ' + expstr + type + ' ' + strike.to_s
		end
		symbol
	end
end


class AtlasAdvancedClient < AtlasClient
	def cancel_all_orders()
		account = account_info
		orders = account["orders"]
		orders.each do |order|
			cancel_order(order)
		end
	end
end


