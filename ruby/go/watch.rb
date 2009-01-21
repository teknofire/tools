#!/usr/bin/env ruby

require 'dgs/user.rb'
require 'dgs/monitor.rb'

if __FILE__ == $0
	m = DgsMonitor.new(ARGV.shift)
	m.run do |games|
		puts "----------------- #{Time.now} ---------------"

		games.each do |id, game|
   		`mumbles-send "New DGS Activity" "#{game[:date]} - #{game[:opponent]}"`
      puts game[:opponent]
    end
	end
end
