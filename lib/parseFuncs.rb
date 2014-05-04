require 'nokogiri'
module TioParse
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

	def self.get_events(filepath)
		#filepath:  	file location of tiopro bracket file
		#returns the events in the tournament
		Nokogiri::XML(open(filepath)).xpath("AppData/EventList/Event/Games/Game").map {|x| x.xpath("Name").text}
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
	def self.calculate_elo_change(winner, loser)
		#Rn = Ro + C * (S - Se)
		expectedScore = 1.0/(1+10**((loser.elo-winner.elo)/400.0))
		newRating = ELO_CONST * 1 * (1-expectedScore)
		#puts newRating
		return newRating.floor
	end
	def self.update_elo_changes(filepath, target_event, elo_ratings)
		#filepath: 		file location of the tiopro bracket file
		#target_event: 	string containing the event you want data for e.g. "Melee Singles"
		#id_hash: 		hash of player IDs, should be used here as playerIDs MAY change over multiple events
		#returns the win/loss data of the event in a hash 
		id_hash = get_id_hash(filepath)
		tioFile = Nokogiri::XML(open(filepath))

		tioFile.xpath("//Game").each do |node|
			if node.xpath("Name").text.downcase == target_event.downcase
				node.xpath("Entrants/Entrant/PlayerID").each do |entrant|
					playerName = id_hash[entrant.text]
					if !elo_ratings.has_key? playerName
						elo_ratings[playerName] = Player.new(playerName)
					end
				end
				node.xpath("Bracket/Matches/Match").each do |match|
					#TODO: make this section not shit 
					player1 = elo_ratings[id_hash[match.xpath("Player1").text]]
					player2 = elo_ratings[id_hash[match.xpath("Player2").text]]

					next if (player1 == nil || player2 == nil) #either player is a bye
					player1.sets+=1
					player2.sets+=1
					winner = elo_ratings[id_hash[match.xpath("Winner").text]]
					next if winner == nil #bracket didn't finish
					loser = (player1 == winner ? player2 : player1)
					winner.beat loser
					loser.lost_to winner
					ratingChange = calculate_elo_change(winner, loser)
					#if (winner.name == "ted" || loser.name == "ted")
					#	puts "Winner: #{winner.name}(#{winner.elo}), Loser: #{loser.name}(#{loser.elo})"
					#	puts "RatingChange: #{ratingChange}"
					#end
					winner.new_elo ratingChange
					loser.new_elo -ratingChange
				end
			end
		end
		return elo_ratings
	end
end