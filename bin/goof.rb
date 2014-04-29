require 'sinatra'
require '../lib/tioParse.rb'

class BracketGroup
	attr_reader :event, :eventData
	def initialize(brackets, event)
		@event = event
		@eventData = []
		dump = File.open("dump.txt", 'w')
		brackets.each do |bracket|
			data = TioParse.parse_tiopro_bracket(bracket, event)
			dump.puts data
			dump.puts "*******************************"
			@eventData.push (data.empty? ? -1 : data)
		end
	end

	def results_addsort(results)
		addedResults = {:wonAgainst => [], :lostAgainst => [], :setsPlayed => 0}
		results.each do |result|
			addedResults[:setsPlayed ] += result[:setsPlayed] if 
			result[:wonAgainst].each {|x| addedResults[:wonAgainst]+=[x] if not addedResults[:wonAgainst].include? x}
			result[:lostAgainst].each {|x| addedResults[:lostAgainst]+=[x] if not addedResults[:lostAgainst].include? x}
		end
		addedResults[:wonAgainst].sort!
		addedResults[:lostAgainst].sort!
		return addedResults
	end

	def player_results(player)
		playerResults = @eventData.map do |x| 
			next if !x.has_key? player
			x[player]
		end
		return results_addsort(playerResults.compact)
	end

end
#checks bracket dir for tio files
def available_brackets()
	Dir["../brackets/*.tio"]
end

test = BracketGroup.new(available_brackets, 'Melee Singles')

get '/' do
  "zxv: #{test.player_results("zxv")}"
end

get %r{\/player=([\w]+)} do
	player = params[:captures].first
	"#{player} results: #{test.player_results(player)}"
end