require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end



#error do
#  e = request.env['sinatra.error']
#  puts e.to_s
#  puts e.backtrace.join('\n')
#  'Application error'
#end
 
helpers do
  def blue(string)
    puts "\n\e[0;34m #{string} \e[m\n\n"
  end
  
  def green(string)
    puts "\n\e[0;32m #{string} \e[m\n\n"
  end
  
  class Fixnum    
    # Returns a string of the integer prefixed with zeros. 
    # Enough zeros will be added so as to make a string that is _characters_ long.
    def width(characters)
      "0"*(characters - self.to_s.size) + self.to_s
    end
  end

  def times_of_day
    times = Proc.new { |suffix| 
        [12].concat((1..11).to_a).map! { |e| 
          [0,15,30,45].map { |f|
            "#{e}:#{f.width(2)} #{suffix}" 
          }
        }.flatten!
      }
  
    times.call("am") << times.call("pm")
  end
end

before do
  blue (params.inspect)
end

get '/' do
  @auditions = Audition.all(:order => [:when.asc])
  haml :list
end

get '/migrateall/jHRo2IRhTjysEz68JlfR' do
  DataMapper.auto_migrate!
  Devtools.load_dev_data
  haml "%h1 Migration Completed. <br />Dev Data Loaded."
end

get '/add' do
  haml :add
end

post '/add' do
  audition_properties = {
                        :when => Time.parse("#{params["when_date"]} #{params["when_time"]}"),
                        :description => params["description"],
                        :where => params["where"],
                        :title => params["title"]
                        }
  @audition = Audition.new(audition_properties)
  @audition.errors.each do |e| 
    puts e 
  end unless @audition.save
  puts @audition.inspect
end

get '/stylesheets/style.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end