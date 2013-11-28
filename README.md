Atlas ATS API Client - Ruby Implementation v1
=============================================

Installation
------------

	gem install atlasats

Usage
-----

Initialize the client

	client = AtlasClient.new('atlasats.hk', 'YOUR_API_KEY')

Place Limit Order Buy 10 Bitcoins (BTC) @ $800/each

	order = client.place_limit_order("BTC", "USD", "BUY", 10.00, 800.00)

