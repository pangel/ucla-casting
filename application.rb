require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end
 
error do
  e = request.env['sinatra.error']
  puts e.to_s
  puts e.backtrace.join('\n')
  'Application error'
end
 
helpers do
  # add your helpers here
end
 
get '/' do
  @auditions = Audition.all(:order => [:when.asc])
  haml :list
end

get '/migrateall/:slug' do
  if params[:slug] == "jHRo2IRhTjysEz68JlfR"
    DataMapper.auto_migrate!
    Devtools.load_dev_data
    haml "%h1 Migration Completed. <br />Dev Data Loaded."
  else
    status 404
  end
end

get '/add' do
  haml :add
end

post '/add' do
  puts params.inspect
  @audition = Audition.new(params)
  @audition.errors.each do |e| 
    puts e 
  end unless @audition.save
  puts @audition.inspect
end

get '/stylesheets/style.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end