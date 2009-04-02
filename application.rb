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

get '/migrateall/jHRo2IRhTjysEz68JlfR' do
  DataMapper.auto_migrate!
  Devtools.load_dev_data
  
  haml "%h1 Migration Completed. <br>Dev Data Loaded."
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