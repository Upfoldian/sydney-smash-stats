require 'sinatra'
require '../lib/tioParse.rb'

class BracketGroup
	attr_reader :event, :eventData
	def initialize(brackets, event)
		@event = event
		@eventData = []
		brackets.each do |bracket|
			data = TioParse.parse_tiopro_bracket(bracket, event)
			@eventData.push (data.empty? ? -1 : data)
		end
	end

	def player_results(player)
		return eventData.has_key? player ? eventData[winner] : []
	end

end
def available_brackets()
	Dir["../brackets/*.tio"]
end

test = BracketGroup.new(available_brackets, 'Melee Singles')
#puts test.event
puts test.eventData.size

get '/' do
  test.eventData[1].to_s
end

#get '/hello' do
#	'asdf'
#end