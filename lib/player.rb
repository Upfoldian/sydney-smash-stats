class Player

	attr_reader :wins, :losses, :name, :elo, :eloChanges, :eventResults
	attr_accessor :sets

	def initialize player
		@wins = []
		@losses = []
		@eventResults = {}
		@sets = 0
		@name = player
		@elo = 1200
		@eloChanges = [1200]
	end

	def beat eventName, *players
		players.each do |player|
			@wins.push player if not @wins.include? player
			@eventResults[eventName] = {:wins => [], :losses => []} if not @eventResults.has_key? eventName
			@eventResults[eventName][:wins].push player
		end

	end

	def lost_to eventName, *players
		players.each do |player|
			@losses.push player if not @losses.include? player
			@eventResults[eventName] = {:wins => [], :losses => []} if not @eventResults.has_key? eventName
			@eventResults[eventName][:losses].push player
		end
	end

	def new_elo newElo
		@elo += newElo
		@eloChanges.push @elo
	end

	def wins_to_s
		wins.map{|player| x.name}
	end

	def losses_to_s
		losses.map{|player| x.name}
	end

	def to_s
		"#{@name}"
	end

end