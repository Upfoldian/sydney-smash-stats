require 'sinatra'
require 'chartkick'
require './lib/TioParse.rb'

#checks bracket dir for tio files
def available_brackets()
	Dir["./brackets/ACT/Canberra Colosseum/*.tio"]
end
searchTitle = 'Brawl Singles'
test = TioParse::BracketGroup.new(available_brackets, searchTitle)

#set :bind, '0.0.0.0'
puts available_brackets.map{|x| x.split('/').last}.map{|x| x[0..-5]}.to_s
puts ""
get '/' do
	erb :index, :locals => {:players => test.eloHash.values.sort_by{|x| x.elo}.reverse, 
							:brackets => available_brackets.map{|x| x.split('/').last}.map{|x| x[0..-5]},
							:bracketTitle => searchTitle}
end

#this needs to be tied with some unique bracket grouping ID or some shit
get '/player=*' do
	player = params[:splat].first
	if test.eloHash.has_key? player
		puts "qwre"
		erb :player, :locals => {:player => test.eloHash[player]}
	else 
		redirect to('/404')
	end
end
get '/404' do
	erb :not_found
end
not_found do
	redirect to('/404')
end