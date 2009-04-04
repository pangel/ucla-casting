require 'application'

set :run, false
set :environment, (ENV['DATABASE_URL'] ? :production : :development)
set :haml, {:format => :html4 }

run Sinatra::Application