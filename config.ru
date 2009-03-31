require 'application'

set :run, false
set :environment, :development
set :haml, {:format => :html4 }

run Sinatra::Application