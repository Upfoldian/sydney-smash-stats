require 'sinatra'
require 'chartkick'
require './lib/TioParse.rb'

#checks bracket dir for tio files
def available_brackets()
	Dir["./brackets/ACT/Canberra Colosseum/*.tio"]
end
def available_events()
	events = []
	available_brackets.each do |x| 
		TioParse.get_events(x).each {|x| events.push x.downcase if !events.include? x.downcase}
	end
	events
end

set :bind, '0.0.0.0'
get '/' do
	erb :index, :locals => {:events => available_events}
end
get '/*/' do
	searchTitle = params[:splat].first
	redirect to('/') if not available_events.include? searchTitle.downcase
	test = TioParse::BracketGroup.new(available_brackets, searchTitle)
	
	players = test.eloHash.values.sort_by{|x| x.elo}.reverse
	brackets = available_brackets.map{|x| x.split('/').last}.map{|x| x[0..-5]}

	erb :events, :locals => {:players => test.eloHash.values.sort_by{|x| x.elo}.reverse, 
							:brackets => available_brackets.map{|x| x.split('/').last}.map{|x| x[0..-5]},
							:bracketTitle => searchTitle}
end

#this needs to be tied with some unique bracket grouping ID or some shit
get '/*/player=*' do
	event = params[:splat].first
	player = params[:splat].last
	puts event
	puts player
	test = TioParse::BracketGroup.new(available_brackets, event)
	if test.eloHash.has_key? player
		puts "qwre"
		erb :player, :locals => {:player => test.eloHash[player]}
	else 
		puts "barf"
		redirect to('/404')
	end
end
get '/404' do
	erb :not_found
end
not_found do
	redirect to('/404')
end