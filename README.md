Atlas ATS API Client - Ruby Implementation v1
=============================================

Installation
------------

	gem install atlasats

Usage WebSockets
----------------

Initialize the client
	EM.run {
		client = AtlasRealtimeClient.new('http://test.atlasats.com/api/v1/streaming', 'API_KEY', 'API_SECRET', API_ACCOUNT)

		client.subscribe_trades do |trade|
			puts "trade: #{trade.inspect}"
		end

		client.subscribe_book do |book|
			puts "book: #{book.inspect}"
		end

		client.subscribe_orders do |order|
			puts "order update"
			puts "\tclient id: #{order[\"oid\"]}"
			puts "\tdata: #{order.inspect}"
		end

		EventMachine.add_timer 10, proc {
			puts "placing limit order"
			$client.place_limit_order "client_order_id", "BTC", "USD", "SELL", 1, 450.50
		}
	}


Usage REST
---------

Initialize the client

	client = AtlasClient.new('atlasats.hk', 'YOUR_API_KEY')
	
Account Information

	accountinfo = client.account_info

Place Limit Order Buy 10 Bitcoins (BTC) @ $800/each

	order = client.place_limit_order("BTC", "USD", "BUY", 10.00, 800.00)

Cancel Order

	client.cancel_order("0-323-2324-4141223")

Get Todays Orders for an Account from the AccountInfo

	client.account_info()["orders"]

Get Information on an Order

	client.order_info(orderid)
	
Subscribe to all trades
	
	client.subscribe_trades do |trade|
		# do something with trade
	end
	
Subscribe to Book updates for a symbol
	
	client.subscribe_book_updates "BTC", "USD" do |book_update|
		# do something with the book update
	end
