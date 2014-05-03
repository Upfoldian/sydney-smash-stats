require 'sinatra'
require './lib/tioParse.rb'

class BracketGroup
	attr_reader :event, :eventData, :eloHash
	def initialize(brackets, event)
		@event = event
		@eventData = []
		@eloHash = {}
		dump = File.open("dump.txt", 'w')
		brackets.each do |bracket|
			data = TioParse.parse_tiopro_bracket(bracket, @event)
			eloHash = TioParse.update_elo_changes(bracket, @event, @eloHash)
			#dump.puts eloHash
 			#dump.puts "\n*******************************\n"
			@eventData.push (data.empty? ? -1 : data)
		end
		dump.puts @eloHash.values.sort_by{|x| x.elo}.reverse
		dump.puts "Elo expected: #{eloHash.size*1200}, Total: #{eloHash.values.map{|x| x.elo}.inject(:+)}"
		dump.close
	end

	def results_addsort(name, results)
		addedResults = TioParse::Player.new(name)
		results.each do |result|
			#puts result
			addedResults.sets = result.sets 
			addedResults.beat *result.wins
			addedResults.lost_to *result.losses
		end
		return addedResults
	end

	def player_results(player_name)
		playerResults = @eventData.map do |x|
			next if not  x.has_key? player_name
			x[player_name]
		end
		return results_addsort(player_name, playerResults.compact)
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
	Dir["./brackets/*.tio"]
end

test = BracketGroup.new(available_brackets, 'PM Singles')

#set :bind, '0.0.0.0'

get '/' do
	puts test.eloHash.values.sort_by{|x| x.elo}.reverse.size
	erb :index, :locals => {:players => test.eloHash.values.sort_by{|x| x.elo}.reverse}
end

#this needs to be tied with some unique bracket grouping ID or some shit
get '/player=*' do
	out = ""
	params[:splat].first.downcase.split(',').each do |player|
		if test.has_player? player
			out += "#{player} results: #{test.player_results(player)}"
		else
			out += "#{player} doesn't EXIST goofball!!!"
		end
	end
	out
end

not_found do
	'Nothin here doofus'
end