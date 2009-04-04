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
  @success = params.has_key? "success" #Flag for flash display after successful audition creation
  
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
  (SHA1.new(params["pwd"]).to_s == "9fdb1a12b37c7b0efc28276fce277e957ebd034f" or localhost?)
  
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
    halt haml "%h2 Resets are only allowed on localhost, during dev." unless localhost?
    DataMapper.auto_migrate!
    halt haml "%h2 Database reset completed"
  when "ADD DEV DATA":
    halt haml "%h2 Loading dev data is only allowed on localhost, during dev."  unless localhost?
    Devtools.load_dev_data
    halt haml "%h2 Dev Data Loaded"
  when "UPGRADE"
    DataMapper.auto_upgrade!
    halt haml "%h2 Upgraded DB schema to fit models."
  end unless params["operation"].nil?
  
  unless params["delete"].nil?
    audition = Audition.get(params["delete"].to_i)
    halt haml "%h2 Audition with id #{id} was not found." if audition.nil?
    title = audition.title
    id = params["delete"]
    audition.destroy
    halt haml "%h2 #{title} (#{id}) was destroyed forever."
  end
  haml "%h2 Your request was malformed (check spelling of operation)"  
end  

get '/add' do
  @audition = {:title => "", :when_date => "", :description => "", :datepicker => "", :when_time => times_of_day[40]}
  
  haml :add
end

post '/add' do
  @audition = {}
  
  @audition[:title] = params["title"] || ""
  @audition[:when_date] = params["when_date"] || ""
  @audition[:description] = params["description"] || ""
  @audition[:where]= params["where"] || ""
  @audition[:when_time] = params["when_time"] || times_of_day[40]
  @audition[:datepicker] = params["datepicker"] || ""

  @audition.map_values! { |value| Sanitize.clean value }
  
  haml :add
end

post '/preview' do
  @preview = {} #Values that will be displayed in the preview box
  
  @preview[:when] = Time.parse("#{params["when_date"]} #{params["when_time"]}").strftime("%A, %B %d %Y at %I:%M%p")
  @preview[:description] = Sanitize.clean params["description"]
  @preview[:where] = Sanitize.clean params["where"]
  @preview[:title] = Sanitize.clean params["title"]
  
  @audition = params #Values that will be sent to the DB. TODO: Check SQL inject & XSS attacks.
  
  haml :preview
end

post '/create' do
  @audition = Audition.new :when => Time.parse("#{params["when_date"]} #{params["when_time"]}"),
                           :description => Sanitize.clean(params["description"]),
                           :where => Sanitize.clean(params["where"]),
                           :title => Sanitize.clean(params["title"])
                        
  @audition.errors.each do |e| 
    puts e 
  end unless @audition.save
  redirect '/?success', 302
end

get '/stylesheets/style.css' do
  response["Content-Type"] = "text/css; charset=utf-8" 
  sass :style
end