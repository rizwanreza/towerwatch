require "rubygems"
require "sinatra"
require "haml"
require "compass"
require "lighthouse-api"
require "yaml"

enable :sessions

set :username, ENV['LIGHTHOUSE_USERNAME']
set :password, ENV['LIGHTHOUSE_PASSWORD']

configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = 'views'
  end
  
  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options

  not_found do
    "We're so sorry, but we don't what this is"
  end

  error do
    "Something really nasty happened.  We're on it!"
  end

end

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/?' do
  if session[:lighthouse_user] && session[:lighthouse_password]
    Lighthouse.account = "rails"
    @project = Lighthouse::Project.find(8994)
    
    unless params[:page]
      params[:page] = 2
    else
      params[:page] = params[:page] + 1
    end
    
    if params[:q]
      @tickets = @project.tickets(:q => params[:q])
      @page_link = "/?q=#{params[:q]}?page=#{params[:page]}"
      haml :tickets
    else
      @tickets = @project.tickets(:q => 'state:open updated:"since 7 days ago"')
      @page_link = "/?q=state:open updated:'since 7 days ago'?page=#{params[:page]}"
      haml :tickets    
    end
  else
    redirect '/lighthouse'
  end
end

post '/prioritize' do
  if params[:priority] != ''
    Lighthouse.account = "rails"
    @project = Lighthouse::Project.find(8994)
    Lighthouse.authenticate(session[:lighthouse_user], session[:lighthouse_password])
    ticket = Lighthouse::Ticket.find(params[:ticket_id], :params => { :project_id => 8994 })
    ticket.priority = params[:priority].to_i
    ticket.save
  else
    "No priority chosen"
  end
end

get '/lighthouse' do
  haml :login, :layout => false
end

post '/lighthouse' do
  session[:lighthouse_user] = params[:lighthouse_user]
  session[:lighthouse_password] = params[:lighthouse_password]
  redirect '/'
end

get '/logout' do
  session[:lighthouse_user] = nil
  session[:lighthouse_password] = nil
  redirect '/'
end

get '/stylesheets/screen.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end