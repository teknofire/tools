require 'open-uri'

class DgsUser
  SITE='http://www.dragongoserver.net/quick_status.php?user='
  GAME_REGEXP=/^'G', (\d+), '(\w+)', '(.)', '(.*)'$/

  attr_reader :username, :quick_status, :games
  def initialize(nick)
    @username = nick
    @games = {}
    @quick_status = ""
  end

  def check
    @quick_status = open(SITE+@username).read
  end
#'G', 463050, 'xath', 'W', '2009-01-13 09:41 GMT'
#'G', 462539, 'ChambersFamily', 'W', '2009-01-13 09:41 GMT'
  def parse
    lines = @quick_status.split("\n").compact
    errors = lines.collect {|l| l if l =~ /^#Error/ }.uniq
    raise "Error for #{@username} - #{errors.inspect}" if errors[0]
    
    @games.each { |id,game| @games[id][:seen] = false }
    lines.each do |l|
      g = GAME_REGEXP.match(l)
      next if g.nil?
      id = g[1].to_i
      
      @games[id] ||= {}

      @games[id] = { 
        :opponent => g[2],
        :date => g[4],
        :seen => true,
        :new => @games[id][:date] != g[4]
      }
    end
    @games.reject! { |id,game| game[:seen] == false }
  end

  def new_games
    @games.reject { |id,game| game[:new] == false }
  end
end

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
