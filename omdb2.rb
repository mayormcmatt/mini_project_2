require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'
require 'pg'


get '/' do
	erb :index
end

post '/result' do
	search_str = params[:movie]
	response = Typhoeus.get("www.omdbapi.com", :params => {:s => search_str})
	# Make a request to the omdb api here!
	search_str = response.body #.body returns JSON string and turns it into Ruby hash
	@parsed = JSON.parse(search_str) #can I tack on ["Search"] and change var. to @var?
	#@parsed= [{"Title"=>"Cars", "Year"=>"2006", "imdbID"=>"tt0317219", "Type"=>"movie"}, ...etc
	# how to redirect if no search results are found
	erb :show
end

get '/poster/:imdb' do
	imdb_id = params["imdb"]
	# Make another api call here to get the url of the poster.
	response = Typhoeus.get("www.omdbapi.com", :params => {:i => "#{imdb_id}"})
	# Make a request to the omdb api here!
	@poster = JSON.parse(response.body)
	erb :poster
end

get '/movies' do
  c = PGconn.new(:host => "localhost", :dbname => "testdb")
  @movies = c.exec_params("SELECT * FROM movies;")
  c.close
  erb :movies
end

def create_movies_table
  c = PGconn.new(:host => "localhost", :dbname => "test")
  c.exec %q{
  CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title TEXT,
    description TEXT,
    rating INTEGER,
    url TEXT
  );
  }
  c.close
end

