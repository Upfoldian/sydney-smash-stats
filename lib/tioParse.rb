require 'nokogiri'

module TioParse

	def self.get_id_hash(filepath)
		#filepath:  	file location of tiopro bracket file
		#returns a hash of playerID to nickname
		id_hash = {}
		tioFile = Nokogiri::XML(open(filepath))

		tioFile.xpath("//Players/Player").each do |node|
			id_hash[node.xpath("ID").text] = node.xpath("Nickname").text.downcase
		end
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
		eventData = Hash.new({:wonAgainst => [], :lostAgainst => [], :setsPlayed => 0})
		id_hash = get_id_hash(filepath)
		tioFile = Nokogiri::XML(open(filepath))

		tioFile.xpath("//Game").each do |node|
			if node.xpath("Name").text.downcase == target_event.downcase
				node.xpath("Entrants/Entrant/PlayerID").each do |entrant|
					if !eventData.has_key? id_hash[entrant.text]
						#puts "Player '#{$id_hash[entrant.text]}' was added"
						eventData[id_hash[entrant.text]] = {:wonAgainst => [], :lostAgainst => [], :setsPlayed => 0}
					end
				end
				node.xpath("Bracket/Matches/Match").each do |match|
					#TODO: make this section not shit
					player1 = id_hash[match.xpath("Player1").text]
					player2 = id_hash[match.xpath("Player2").text]
					eventData[player1][:setsPlayed]+=1
					eventData[player2][:setsPlayed]+=1
					winner = id_hash[match.xpath("Winner").text]
					loser = (player1 == winner ? player2 : player1)
					eventData[winner][:wonAgainst].push(loser) unless eventData[winner][:wonAgainst].include?(loser)
					eventData[loser][:lostAgainst].push(winner) unless eventData[winner][:lostAgainst].include?(winner)
				end
			end
		end
		return eventData
	end
end