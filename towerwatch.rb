require "rubygems"
require "sinatra"
require "haml"
require "compass"
require "lighthouse-api"
require "yaml"

set :username, ENV['LIGHTHOUSE_USERNAME']
set :password, ENV['LIGHTHOUSE_PASSWORD']

configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = 'views'
  end
  
  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options
end

before do
  headers "Content-Type" => "text/html; charset=utf-8"
  Lighthouse.account = "rails"
  @project = Lighthouse::Project.find(8994)
end

get '/?' do
  if params[:q]
    @tickets = @project.tickets(:q => params[:q])
    unless params[:page]
      params[:page] = 2
    else
      params[:page] = params[:page] + 1
    end
    @page_link = "/?q=#{params[:q]}?page=#{params[:page]}"
    haml :tickets
  else
    @tickets = @project.tickets(:q => 'state:open updated:"since 7 days ago"')
    @page_link = "/?q=state:open updated:'since 7 days ago'?page=#{params[:page]}"
    haml :tickets    
  end
end

post '/prioritize' do
  if params[:priority] != ''
    Lighthouse.authenticate(ENV['LIGHTHOUSE_USERNAME'], ENV['LIGHTHOUSE_PASSWORD'])
    ticket = Lighthouse::Ticket.find(params[:ticket_id], :params => { :project_id => 8994 })
    ticket.priority = params[:priority].to_i
    if ticket.save
      "Submitted #{params[:priority]} priority for ticket ID: #{params[:ticket_id]}"
    end
  else
    "No priority chosen"
  end
end

# Sass stylesheet
get '/stylesheets/screen.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end