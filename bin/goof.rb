#require 'sinatra'
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
			dump.puts "\n*******************************\n"
			@eventData.push (data.empty? ? -1 : data)
		end
		dump.close
	end

	def results_addsort(results)
		addedResults = TioParse::Player.new("combine")
		results.each do |result|
			addedResults.sets += result.sets 
			result.wins.each {|x| addedResults.beat x}
			result.losses.each {|x| addedResults.lost_to x}
		end
		return [:wins => addedResults.wins.sort, :losses => addedResults.losses.sort]
	end

	def player_results(player)
		playerResults = @eventData.map do |x| 
			x.has_key? player ? x[player] : nil 
		end
		return results_addsort(playerResults.compact)
	end

	def get_entrants(bracket)
		return bracket.keys
	end

	def has_player?(name)
		return eventData.any? {|event| event.has_key? name}
	end

end
#checks bracket dir for tio files
def available_brackets()
	Dir["../brackets/*.tio"]
end

test = BracketGroup.new(available_brackets, 'Melee Singles')

#get '/' do
#	"zxv: #{test.player_results("zxv")}"
#end

#this needs to be tied with some unique bracket grouping ID or some shit
#get '/player=*' do
#	out = ""
#	params[:splat].first.downcase.split(',').each do |player|
#		if test.has_player? player
#			out += "#{player} results: #{test.player_results(player)}"
#		else
#			out += "#{player} doesn't EXIST goofball!!!"
#		end
#	end
#	out
#end