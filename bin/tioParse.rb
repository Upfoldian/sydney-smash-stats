require 'nokogiri'

module TioParse

	def self.get_id_hash(filepath)
		id_hash = {}
		tioFile = Nokogiri::XML(open(filepath))

		tioFile.xpath("//Players/Player").each do |node|
			id_hash[node.xpath("ID").text] = node.xpath("Nickname").text
		end

		return id_hash
	end

	def self.parse_tiopro_bracket(filepath, target_event, id_hash)
		eventData = Hash.new({:wonAgainst => [], :lostAgainst => [], :setsPlayed = 0})
		tioFile = Nokogiri::XML(open(filepath))

		tioFile.xpath("//Game").each do |node|
			if node.xpath("Name").text.downcase == target_event
				node.xpath("Entrants/Entrant/PlayerID").each do |entrant|
					if !eventData.has_key? id_hash[entrant.text]
						#puts "Player '#{$id_hash[entrant.text]}' was added"
						winLoss[id_hash[entrant.text]] = {:wonAgainst => [], :lostAgainst => [], :setsPlayed = 0}
					end
				end
				node.xpath("Bracket/Matches/Match").each do |match|
					player1 = id_hash[match.xpath("Player1").text]
					player2 = id_hash[match.xpath("Player2").text]
					winner = id_hash[match.xpath("Winner").text]
					loser = (player1 == winner ? player2 : player1)

					eventData[winner][:wonAgainst].push(loser) unless eventData[winner][:wonAgainst].has_value?(loser)
					eventData[loser][:lostAgainst].push(winner) unless eventData[winner][:lostAgainst].has_value?(winner)
				end
			end
		end
	end
end


class BracketData

end