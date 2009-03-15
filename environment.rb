require 'dm-core'
require 'dm-validations'
require 'haml'
require 'sinatra' unless defined?(Sinatra)
require 'devtools'

configure do

 DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:///my.db')
 
  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
end

configure :development do

end