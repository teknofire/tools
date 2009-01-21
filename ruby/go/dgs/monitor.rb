class DgsMonitor
	def initialize(user)
		@sleep_factor = 0.25
		@unchanged_count = -1

		@user = DgsUser.new(user)
	end
	
	def sleep_time
		30 + 30 * @sleep_factor * @unchanged_count
	end
	
	def new_games?
		@user.check
		@user.parse

		if @user.new_games.empty?
			increment
		else
			reset
		end

		return !@user.new_games.empty?
	end

	def increment
		return if @unchanged_count > 12
		@unchanged_count += 1
	end

	def reset
		@unchanged_count = 0
	end

	def run(&block)
		loop do
			yield @user.new_games if new_games?
			sleep sleep_time
		end
	end
end
