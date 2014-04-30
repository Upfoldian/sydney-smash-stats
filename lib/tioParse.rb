require 'nokogiri'
module TioParse

	class Player

		attr_reader :wins, :losses, :name
		attr_accessor :sets

		def initialize player
			@wins = []
			@losses = []
			@sets = 0
			@name = player
		end

		def beat player
			@wins.push player unless @wins.include? player
		end

		def lost_to player
			@losses.push player unless @losses.include? player
		end

		def to_s
			"Name: '#{@name}'\n    Won against: #{@wins.map{|x| x.name}}\n    Lost against: #{@losses.map{|x| x.name}}\n    Sets played: #{@sets}\n"
		end

	end
	#TODO: MAKE THIS
	#class Result < Hash
	#
	#end

	def self.get_id_hash(filepath)
		#filepath:  	file location of tiopro bracket file
		#returns a hash of playerID to nickname
		id_hash = {}
		tioFile = Nokogiri::XML(open(filepath))
		#puts "getting file at #{filepath}"
		tioFile.xpath("//Player").each do |node|
			#puts "ID: #{node.xpath("ID").text}\nNick: #{node.xpath("Nickname").text}"
			id_hash[node.xpath("ID").text] = node.xpath("Nickname").text.downcase
		end
		id_hash["00000001-0001-0001-0101-010101010101"] = "Bye"
		return id_hash
	end

	def self.get_name(filepath)
		#filepath:  	file location of tiopro bracket file
		#returns the name of the tournament e.g. "RoS 1"
		Nokogiri::XML(open(filepath)).xpath("AppData/EventList/Event/Name").text
	end
	
	def self.parse_tiopro_bracket(filepath, target_event)
		#filepath: 		file location of the tiopro bracket file
		#target_event: 	string containing the event you want data for e.g. "Melee Singles"
		#id_hash: 		hash of player IDs, should be used here as playerIDs MAY change over multiple events
		#returns the win/loss data of the event in a hash 
		eventData = Hash.new
		id_hash = get_id_hash(filepath)
		tioFile = Nokogiri::XML(open(filepath))

		tioFile.xpath("//Game").each do |node|
			if node.xpath("Name").text.downcase == target_event.downcase
				node.xpath("Entrants/Entrant/PlayerID").each do |entrant|
					playerName = id_hash[entrant.text]
					if !eventData.has_key? playerName
						eventData[playerName] = Player.new(playerName)
					end
				end
				node.xpath("Bracket/Matches/Match").each do |match|
					#TODO: make this section not shit 
					player1 = eventData[id_hash[match.xpath("Player1").text]]
					player2 = eventData[id_hash[match.xpath("Player2").text]]

					next if (player1 == nil || player2 == nil) #either player is a bye
					player1.sets+=1
					player2.sets+=1
					winner = eventData[id_hash[match.xpath("Winner").text]]
					next if winner == nil #bracket didn't finish
					loser = (player1 == winner ? player2 : player1)
					winner.beat loser
					loser.lost_to winner
				end
			end
		end
		return eventData
	end
end