require 'dm-core'
require 'dm-validations'
require 'haml'
require 'sanitize'
require 'sinatra' unless defined?(Sinatra)
require 'devtools'


configure do

 DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:///my.db')
 
  # load models and extensions
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
end

configure :development do

end