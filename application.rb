require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

helpers Helpers, DevelopmentHelpers #Located at lib/extensions.rb

before do
  response["Content-Type"] = "text/html; charset=utf-8"
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

get '/' do
  # Define flashes
  define_flashes params
  @auditions = Audition.all(:when.gt => Time.now, :order => [:when.asc])
  haml :list
end

get '/admin' do
  @migrations = Devtools.migrations.singleton_methods
  haml :admin
end

post '/admin' do
  require 'sha1'
  throw(:halt, [401, "Not authorized\n"]) and return unless \
  (SHA1.new(params["pwd"]).to_s == "9fdb1a12b37c7b0efc28276fce277e957ebd034f" or dev_env?)
  
  unless params["migration"].nil?
    if Devtools.migrations.singleton_methods.include? params["migration"]
      Devtools.migrations.send(params["migration"].to_sym)
      halt haml "%h2 Migration #{params["migration"]} done."
    else
      halt haml "%h2 Migration #{params["migration"]} is unknown."
    end
  end
  
  case params["operation"].upcase
  when "RESET":
    halt haml "%h2 Resets are only allowed in development." unless dev_env?
    DataMapper.auto_migrate!
    halt haml "%h2 Database reset completed"
  when "ADD DEV DATA":
    halt haml "%h2 Loading dev data is only allowed in development."  unless dev_env?
    Devtools.load_dev_data
    halt haml "%h2 Dev Data Loaded"
  end unless params["operation"].nil?
  
  unless params["delete"].nil?
    sha1 = params["delete"]
    audition = Audition.first(:sha1 => sha1)
    halt haml "%h2 Audition with sha1 #{sha1} was not found." if audition.nil?
    
    audition.destroy
    halt haml "%h2 #{audition.title} (#{sha1}) was destroyed forever."
  end
  haml "%h2 Your request was malformed (check spelling of operation)"  
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

get '/stylesheets/style.css' do
  response["Content-Type"] = "text/css; charset=utf-8" 
  sass :style
end