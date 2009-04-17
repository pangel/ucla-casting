require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

helpers Helpers, DevelopmentHelpers #Located at lib/extensions.rb

before do
  response["Content-Type"] = "text/html; charset=utf-8"
end

get '/' do
  # Define flashes
  define_flashes params
  
  @auditions = Audition.all(:when.gt => Time.now, :order => [:when.asc])
  haml :list
end

get '/add' do
  @audition = AUDITION_DEFAULTS
  
  haml :add
end

post '/add' do
  @audition = audition_from params
  
  haml :add
end

post '/preview' do
  @audition = audition_from params
  @validatable_audition = Audition.create_with params

  if not @validatable_audition.valid?
    @errors = @validatable_audition.errors
    halt(haml :add) 
  end
  
  @preview = Hash.new
  
  @preview[:when] = Time.parse("#{params["when_date"]} #{params["when_time"]}").strftime("%A, %B %d %Y at %I:%M%p")
  @preview[:description] = Sanitize.clean params["description"]
  @preview[:where] = Sanitize.clean params["where"]
  @preview[:title] = Sanitize.clean params["title"]

  haml :preview
end

post '/create' do
  @audition = Audition.create_with(params)
                        
  if @audition.save
    redirect '/?success', 302
  else
    puts @audition.errors.inspect
    redirect '/?duplicate', 302 if @audition.errors.include? ["Sha1 is already taken"]
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