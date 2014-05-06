require 'sinatra'
require 'chartkick'
require './lib/TioParse.rb'

#checks bracket dir for tio files
def available_brackets()
	Dir["./brackets/Cur/*.tio"]
end

def order_brackets(*brackets)
	brackets.sort_by {|file| Nokogiri::XML(open(file)).xpath("AppData/EventList/Event/StartDate").text}
end

def available_singles_events()
	events = []
	order_brackets(*available_brackets).each do |bracket|
		TioParse.get_events(bracket).each do |event|
			x = event.downcase 
			next if not x.include?("singles")
			events.push x if not events.include? x
		end
	end
	events
end


set :bind, '0.0.0.0'

get '/' do
	erb :index, :locals => {:events => available_singles_events}
end

get '/*/' do
	searchTitle = params[:splat].first
	redirect to('/') if not available_singles_events.include? searchTitle.downcase
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
	test = TioParse::BracketGroup.new(available_brackets, event)
	if test.eloHash.has_key? player
		erb :player, :locals => {:player => test.eloHash[player]}
	else 
		redirect to('/404')
	end
end

get '/about' do
	erb :about
end

get '/contact' do
	erb :contact
end

get '/404' do
	erb :not_found
end

not_found do
	redirect to('/404')
end