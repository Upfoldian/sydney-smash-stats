require 'sinatra'
require 'chartkick'
require './lib/TioParse.rb'

#checks bracket dir for tio files
def tio_files()
	Dir["./brackets/Cur/*.tio"]
end

def order_brackets(*brackets)
	temp = []
	brackets.each do |file|
		a = Nokogiri::XML(open(file)).xpath("AppData/EventList/Event/StartDate").text.split.first
		puts a
		puts Date.strptime(a, "%d/%m/%Y").to_s
	end
end

def get_singles(*brackets)
	singles = []
	brackets.each do |bracket|
		TioParse.get_events(bracket).each do |event|
			next if not event.downcase.include? "singles"
			singles << event.downcase if not singles.include? event.downcase
		end
	end
	singles
end

orderedBrackets = order_brackets *tio_files

#set :bind, '0.0.0.0'

get '/' do
	erb :index, :locals => {:events => get_singles(*orderedBrackets)}
end

get '/*/' do
	searchTitle = params[:splat].first
	if !get_singles(*orderedBrackets).include? searchTitle.downcase
		redirect to('/') 
	end
	test = TioParse::BracketGroup.new(orderedBrackets, searchTitle)
	
	players = test.eloHash.values.sort_by{|x| x.elo}.reverse
	brackets = orderedBrackets.map{|x| x.split('/').last}.map{|x| x[0..-5]}

	erb :events, :locals => {:players => players, 
							:brackets => brackets,
							:bracketTitle => searchTitle}
end

#this needs to be tied with some unique bracket grouping ID or some shit
get '/*/player=*' do
	event = params[:splat].first
	player = params[:splat].last

	test = TioParse::BracketGroup.new(orderedBrackets, event)
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