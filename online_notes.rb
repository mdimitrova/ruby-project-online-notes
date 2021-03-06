require 'rubygems'
require 'bundler/setup'
require 'sinatra'

enable :sessions
enable :logging
set :session_secret, 'super secret'

Dir.glob('./{models}/*.rb').each { |file| require file }

get '/' do
  haml :home, locals: {:welcome_message => "Welcome to Online notes :)"}
end

get '/login' do
  haml :login
end

post '/login' do
  user = User.authenticate(params[:username], params[:password])
  if user
    session[:user] = user
    redirect "/notes"
  else
    haml :login, locals: {:authentication_error => "Incorrect login data. Try again"}
  end
end

get '/register' do
  haml :register
end

post '/register' do
  user = User.new(params)
  if user.valid?
    user.save
    session[:user] = user
    redirect "/notes"
  else
    haml :register, locals: {:registration_error => user.errors}
  end
end

get '/notes' do
  @notes = Note.where :user_id => session[:user].id
  haml :notes
end

get '/notes/create' do
  haml :create
end

post '/notes/create' do
  note = Note.new()
  note.title = params[:title]
  note.text = params[:text]
  note.tags = params[:tags]
  note.notebook = params[:notebook]
  note.user_id = session[:user].id
  note.save
  haml :notes
  redirect '/notes'
end

get '/note/:note_id' do
  @note = Note.find :id => params[:note_id]
  if @note
    if @note.user_id.eql? session[:user].id
      haml :note
    else
     haml :not_authorized
    end
  else
    redirect '/not_found'
  end
end

get '/note/:note_id/edit' do
  @note = Note.find :id => params[:note_id]
  if @note
    if @note.user_id.eql? session[:user].id
      haml :edit
    else
     haml :not_authorized
    end
  else
    redirect 'not_found'
  end
end

post '/note/:note_id/edit' do
 @note = Note.find :id => params[:note_id]
  if @note
    if @note.user_id.eql? session[:user].id
      @note.title = params[:title]
      @note.text = params[:text]
      @note.tags = params[:tags]
      @note.notebook = params[:notebook]
      @note.save
      redirect "/note/#{params[:note_id]}"
      haml :note
    else
     haml :not_authorized
    end
  else
    redirect '/not_found'
  end
end

get '/notebooks' do
  haml :notebooks
end

get '/tags' do
  @tags = []
  all_notes = Note.where :user_id => session[:user].id
  all_notes.each do |note|
    @tags << note.tags
  end
  @tags.flatten!
  @tags.uniq! unless @tags.nil?
  haml :tags
end

get '/tags/:tag' do
  @notes = Note.where :user_id => session[:user].id, :tags => params[:tag]
  haml :notes, locals: {selected_notes: @notes}
end

get '/logout' do
  session.delete :user
  redirect '/'
end

not_found do
  haml :not_found
end
