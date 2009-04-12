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

 DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:///my.db')
 
  # load models and extensions
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
  
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib/models")
  Dir.glob("#{File.dirname(__FILE__)}/lib/models/*.rb") { |model| require File.basename(model, '.*') }

  DataMapper.auto_upgrade!
  
  # Constants
  
  SMTP_SETTINGS = {
  :host        => "smtp.gmail.com",
  :port           => 587,
  :domain         => "uclacasting@gmail.com",
  :auth => :plain,
  :user      => "uclacasting@gmail.com",
  :password       => ENV['SMTP_PASSWORD'] || "WRONG-PASSWORD!"
  }
end

configure :development do

end