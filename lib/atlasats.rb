require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'httparty'
require 'faye'
require 'json'
require 'time'

class AtlasClient
	include HTTParty
	
	def initialize(buri, apikey)
		# strip out 'http://' or 'https://' since it's no longer the user's choice
		cleanuri = buri.gsub(/http:\/\/|https:\/\//, '')
		## Only production environments require HTTPS
		# Use HTTP if the base URI matches either:
		# - 'test.*' OR
		# - 'dev.*'
		prefix = /^test\.|^dev\./.match(cleanuri).nil? ? 'https://' : 'http://'
		# produce the correct @baseuri
		@baseuri = prefix + cleanuri
		@options = { :headers => { "Authorization" => "Token token=\"#{apikey}\"" }, :base_uri => HTTParty.normalize_base_uri(@baseuri) }
	end
	
	def with_auth(body=nil, &block)
		r = block.call(body.nil? ? @options : @options.merge(:body => body))
		r.parsed_response
	end

	def with_auth_query(body=nil, &block)
		r = block.call(body.nil? ? @options : @options.merge(:query => body))
	end
	
	def place_market_order(item, currency, side, quantity)
		with_auth :item => item, :currency => currency, :side => side, :quantity => quantity, :type => "market" do |options|
			self.class.post("/api/v1/orders", options)
		end
	end
	
	def place_limit_order(item, currency, side, quantity, price)
		with_auth :item => item, :currency => currency, :side => side, :quantity => quantity, :type => "limit", :price => price do |options|
			self.class.post("/api/v1/orders", options)
		end
	end
	
	def order_info(orderid)
		with_auth_query nil do |options|
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
		with_auth_query nil do |options|
			self.class.get('/api/v1/account', options)
		end
	end

	# market data
	def book(item, currency)
		with_auth_query :item => item, :currency => currency do |options|
			self.class.get('/api/v1/market/book', options)
		end
	end

	def recent_trades(item, currency)
		with_auth_query :item => item, :currency => currency do |options|
			self.class.get('/api/v1/market/trades/recent', options)
		end
	end
	
	# market data
	def subscribe_quotes(&block)
		Thread.new do
			EM.run {
				client = Faye::Client.new("#{@baseuri}:4000/api")
				client.subscribe("/quotes") do |msg|
					block.call(msg)
				end
			}
		end
	end
	
	def subscribe_trades(&block)
		Thread.new do
			EM.run {
				client = Faye::Client.new("#{@baseuri}:4000/api")
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
				client = Faye::Client.new("#{@baseuri}:4000/api")
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
end
