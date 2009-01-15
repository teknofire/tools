#!/usr/bin/env ruby

require 'dgs.rb'

if __FILE__ == $0
  u = DgsUser.new(ARGV.shift)
  loop do
    u.check
    u.parse

    unless u.new_games.empty?
      puts "----------------- #{Time.now} ---------------"
      u.new_games.each do |id, game|
        `mumbles-send "New DGS Activity" "#{game[:date]} - #{game[:opponent]}"`
        puts game[:opponent]
      end
    end

    sleep 30
  end
end
