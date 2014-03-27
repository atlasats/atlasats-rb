#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'atlasats'
require './util'



### Retrieve lists of traded assets ###



# See helper class 'Util' in util.rb
client = Util.logon

# See what coins are traded on Atlas
puts 'Atlas ATS currently supports:'
client.coins().each do |symbol|
	puts '- ' + symbol["item"]
end

# Option chain
underliers = {}
client.options().each do |symbol|
	undly = symbol["undly"]
	underliers[undly] = 0 if underliers[undly].nil?
	underliers[undly] += 1
end


puts 'Atlas ATS also supports options on:'
underliers.each do |undly|
	puts '- ' + undly[0] + ' (' + undly[1].to_s + ' contracts)'
end
