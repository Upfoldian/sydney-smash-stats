require 'sinatra'
#require 'sinatra'
require './lib/tioParse.rb'

#set :bind, '0.0.0.0'
#set :port, 80

orderedBrackets = TioParse.order_brackets *TioParse.tio_files
get '/' do
	erb :index, :locals => {:events => TioParse.get_singles(*orderedBrackets)}
end

get '/*/' do
	searchTitle = params[:splat].first
	if !TioParse.get_singles(*orderedBrackets).include? searchTitle.downcase
		redirect to('/') 
	end
	test = TioParse::BracketGroup.new(orderedBrackets, searchTitle)

	players = test.eloHash.values.sort_by{|x| x.elo}.reverse

	playerData = [["Player", "Elo"]]
	players.each do |x|
	 	next if x == nil
	 	playerData << [x.name, x.elo]
	end 

	slices = players.each_slice((players.size/3.0).ceil).to_a
	while slices.last.length < slices.first.length
		slices.last << nil
	end
	players = slices.transpose.flatten

	brackets = orderedBrackets.map{|x| x.split('/').last}.map{|x| x[0..-5]}

	erb :events, :locals => {:players => players, 
							 :brackets => brackets,
							 :playerData => playerData,
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

