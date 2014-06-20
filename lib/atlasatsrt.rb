require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'faye'
require 'json'
require 'time'

class HmacAuthExt
	def initialize(key, secret)
		@key = key
		@secret = secret
	end

	def outgoing(message, callback)
		path = message['channel']

		ident = generate_ident(path, message['data'])

		# todo:
		message['ext'] ||= {}
		message['ext']['ident'] = ident

		callback.call(message)
	end

	def incoming(message, callback)
		callback.call(message)
	end

	private

	def generate_ident(path, body)
		nounce = generate_nounce
		signature = generate_signature(nounce, path, body)
		ident = { 
			"key" => @key,
			"signature" => signature,
			"nounce" => nounce
		}
	end

	def generate_signature(nounce, path, body)
		raw_signature = "#{@key}:#{nounce}:#{path}:#{body}"

		return OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret, raw_signature)
	end

	def generate_nounce
		Time.now.to_i
	end

end

class AtlasRealtimeClient
	def initialize(url, key, secret, account_id)
		@url = url
		@key = key
		@secret = secret
		@account_id = account_id

		@client = Faye::Client.new(@url)
		@client.add_extension(HmacAuthExt.new(@key, @secret))
	end

	# symbols = nil for all symbols, otherwise please provide array
	def request_spinup
		# account
		#  -> account params
		request_spinup_accountinfo
		#  -> recent orders
		request_spinup_orders
		# market data
		request_spinup_book
	end

	def subscribe_orders(&block)
		@client.subscribe "/account/#{@account_id}/orders" do |message|
			order = JSON.parse(message)
			block.call(order)
		end
	end

	def subscribe_trades(&block)
		@client.subscribe "/trades" do |message|
			trade = JSON.parse(message)
			block.call(trade)
		end
	end

	def subscribe_book(&block)
		@client.subscribe "/market" do |message|
			book = JSON.parse(message)
			block.call(book)
		end
	end

	def place_limit_order(client_order_id, item, currency, side, quantity, price)
		send_action(:action => "order:create", :item => item, :currency => currency, :side => side, :quantity => quantity, :type => "limit", :price => price, :clid => client_order_id)
	end

	def place_market_order(client_order_id, item, currency, side, quantity)
		send_action(:action => "order:create", :item => item, :currency => currency, :side => side, :quantity => quantity, :type => "market", :clid => client_order_id)
	end

	def cancel_order(orderid)
		send_action(:action => "order:cancel", :oid => orderid)
	end

	private

	def send_action(obj)
		@client.publish("/actions", to_message(obj))
	end

	def request_spinup_accountinfo
		create_request!(:type => "account")
	end

	def request_spinup_orders
		create_request!(:type => "orders")
	end

	def request_spinup_book
		create_request!(:type => "book")
	end

	def create_request!(obj)
		@client.publish("/requests/#{@account_id}", to_message(obj))
	end

	def to_message(obj)
		obj.to_json
	end
end
