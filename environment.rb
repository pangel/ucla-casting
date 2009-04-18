require 'sha1'
require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'haml'
require 'sanitize'
require 'smtp-tls'
require 'pony'
require 'sinatra' unless defined?(Sinatra)
require 'devtools'


configure do
  
  # Constants required by the helpers
  SITE_URL = "http://simple-light-15.heroku.com"
      
  SMTP_SETTINGS = {
  :host        => "smtp.gmail.com",
  :port           => 587,
  :domain         => "uclacasting@gmail.com",
  :auth => :plain,
  :user      => "uclacasting@gmail.com",
  :password       => ENV['SMTP_PASSWORD'] || "WRONG-PASSWORD!"
  }
  
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:///my.db')
 
  # load models and extensions
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
  
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib/models")
  Dir.glob("#{File.dirname(__FILE__)}/lib/models/*.rb") { |model| require File.basename(model, '.*') }

  DataMapper.auto_upgrade!
  

  # Constants that require the helpers
  # Generates an array of all times from 12:00am to 12:00pm, with 15 minutes increments. Result should be cached.
  TIMES_OF_DAY = begin
    times = Proc.new { |suffix| 
        [12].concat((1..11).to_a).map! { |e| 
          [0,15,30,45].map { |f|
            "#{e.width(2)}:#{f.width(2)} #{suffix}" 
          }
        }.flatten!
      }
    times.call("am") + times.call("pm")
  end
end

configure :development do

end