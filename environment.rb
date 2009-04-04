require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'haml'
require 'sanitize'
require 'sinatra' unless defined?(Sinatra)
require 'devtools'


configure do

 DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:///my.db')
 DataMapper.auto_upgrade!
  # load models and extensions
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
  
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib/models")
  Dir.glob("#{File.dirname(__FILE__)}/lib/models/*.rb") { |model| require File.basename(model, '.*') }

end

configure :development do

end