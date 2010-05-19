require "rubygems"
require "sinatra"
require "haml"
require "lighthouse-api"
require "yaml"

set :username, ENV['LIGHTHOUSE_USERNAME']
set :password, ENV['LIGHTHOUSE_PASSWORD']

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
    haml :search
  end
end

post '/prioritize' do
  if params[:priority] != ''
    Lighthouse.authenticate(settings.username, settings.password)
    ticket = Lighthouse::Ticket.find(params[:ticket_id], :params => { :project_id => 8994 })
    ticket.priority = params[:priority].to_i
    if ticket.save
      "Submitted #{params[:priority]} priority for ticket ID: #{params[:ticket_id]}"
    end
  else
    "No priority chosen"
  end
end

