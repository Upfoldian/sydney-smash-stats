class Player

	attr_reader :wins, :losses, :name, :elo, :eloChanges
	attr_accessor :sets

	def initialize player
		@wins = []
		@losses = []
		@sets = 0
		@name = player
		@elo = 1200
		@eloChanges = [1200]
	end

	def beat *players
		players.each {|player| @wins.push player unless @wins.include? player}
	end

	def lost_to *players
		players.each {|player| @losses.push player unless @losses.include? player}
	end

	def new_elo newElo
		@elo += newElo
		@eloChanges.push @elo
	end

	def to_s
		"Name: '#{@name}'\n"+
		"    Won against: #{@wins.map{|x| x.name}.sort}\n"+
		"    Lost against: #{@losses.map{|x| x.name}.sort}\n"+
		"    Sets played: #{@sets}\n"+
		"    Elo: #{@elo}\n"
	end

end