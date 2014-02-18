require 'sinatra'

enable :sessions
enable :logging

Dir.glob('./{models}/*.rb').each { |file| require file }

get '/' do
  haml :home
end

get '/login' do
  haml :login
end

get '/register' do
  haml :register
end

get '/notes' do
  haml :notes
end

get '/notebooks' do
  haml :notebooks
end

get '/tags' do
  haml :tags
end

get '/logout' do
  haml :logout
end

not_found do
  haml :not_found
end

