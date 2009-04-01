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
  
  # Monkey patches
  
  class Fixnum    
    # Returns a string of the integer prefixed with zeros. 
    # Enough zeros will be added so as to make a string that is _characters_ long.
    def width(characters)
      "0"*(characters - self.to_s.size) + self.to_s
    end
  end
  
  class String
    def nl2br
      self.gsub(/\n/, '<br />')
    end
  end
  
  class Time
    def to_delay
      # Process the duration between two dates in natural language.
      # _self_ is assumed to be greater than Time.now
      # Many edge cases: last day of week, last day of month, last day of year ...
      now = Time.now
      if self.yday == now.yday
        "Today"
      elsif self.yday == now.yday+1 and self.year == now.year
        "Tomorrow"
      elsif self.strftime("%W").to_i == now.strftime("%W").to_i+1
        "Next week"
      elsif self.month == now.month+1
        "Next month"
      else
        "Later"
      end unless self.year != now.year # We don't want to compare 2k9 to 2k10.
    end
  end
  
  class Hash
    def map_values! &block
      each_pair { |k,v| store(k,block.call(v)) }
    end
  end
  
  def blue(string)
    puts "\n\e[0;34m #{string} \e[m\n\n"
  end
  
  def green(string)
    puts "\n\e[0;32m #{string} \e[m\n\n"
  end
  


  def times_of_day
    times = Proc.new { |suffix| 
        [12].concat((1..11).to_a).map! { |e| 
          [0,15,30,45].map { |f|
            "#{e}:#{f.width(2)} #{suffix}" 
          }
        }.flatten!
      }
  
    times.call("am") + times.call("pm")
  end
end

before do
  blue (params.inspect)
end

get '/' do
  @success = params.has_key? "success"
  @auditions = Audition.all(:order => [:when.asc])
  haml :list
end

get '/migrateall/jHRo2IRhTjysEz68JlfR' do
  DataMapper.auto_migrate!
  Devtools.load_dev_data
  haml "%h1 Migration Completed. <br />Dev Data Loaded."
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
  green @audition[:datepicker]
  @audition.map_values! { |value| Sanitize.clean value }
  haml :add
end

post '/preview' do
  @preview = {}
  @preview[:when] = Time.parse("#{params["when_date"]} #{params["when_time"]}").strftime("%A, %B %d %Y at %I:%M%p")
  @preview[:description] = Sanitize.clean params["description"]
  @preview[:where] = Sanitize.clean params["where"]
  @preview[:title] = Sanitize.clean params["title"]
  
  @audition = params
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
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end