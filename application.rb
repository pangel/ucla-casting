require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

helpers Helpers, DevelopmentHelpers

before do
  response["Content-Type"] = "text/html; charset=utf-8"
end

get '/' do
  define_flashes params
  
  @auditions = Audition.all(:when.gt => Time.now, :order => [:when.asc])
  haml :list
end

get '/add' do
  @audition = Audition.new
  haml :add
end

post '/add' do
  @audition = Audition.clean_new params

  haml :add
end

get '/edit' do
  halt 404, "Not found" unless @audition = Audition.first(:sha1 => params["id"])
  
  @edit = true
  haml :add
end

post '/edit' do
  @audition = authenticate!(params["sha1"],params["pwd"],params["email"])
  
  @audition.clean_change params

  if @audition.update
    redirect '/?edited', 302
  else
    puts @audition.errors.inspect
    redirect '/?error', 302
  end
end  

get '/delete' do
  @sha1 = params["id"]
  haml :delete
end

post '/delete' do
  @audition = authenticate!(params["sha1"],params["pwd"],params["email"])
  @audition.destroy
  redirect '/?deleted', 302
end

post '/preview' do
  @audition = Audition.first(:sha1 => params["sha1"]) || Audition.new

  @audition.clean_change params  

  if not @audition.valid?
    @errors = @audition.errors
    halt(haml :add) 
  end
  
  @edit = true unless @audition.new_record?
  haml :preview
end

post '/create' do
  @audition = Audition.clean_new params
  pwd = @audition.pwd                  
  if @audition.save
    notify(@audition,pwd)
    redirect '/?created', 302
  else
    puts @audition.errors.inspect
    redirect '/?error', 302
  end
end



get '/feedback' do
  haml :feedback
end

post '/feedback' do
  define_flashes params
  redirect '?/feedback_blank' if params[:body].nil? or params[:body].blank?
  
  body = "From: " + Sanitize.clean(params[:email] || "no email given") + "\n\n" + params[:body]
  
  begin
    Pony.mail :to => 'pangel.neu@gmail.com', :subject => "Feedback from uclacasting", :body => body, :via => :smtp, :smtp => SMTP_SETTINGS
    redirect '/?feedback_success'
  rescue
    puts "FEEDBACK SENDING FAILED: " + $!
    redirect '/?feedback_failure'
  end
end

# Sass stylesheet
get '/stylesheets/style.css' do
  response["Content-Type"] = "text/css; charset=utf-8" 
  sass :style
end

# Administration section
load 'admin_routes.rb'