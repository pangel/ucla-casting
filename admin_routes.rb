get '/admin' do
  @migrations = Devtools.migrations.singleton_methods
  haml :admin
end

post '/admin' do
  require 'sha1'
  throw(:halt, [401, "Not authorized\n"]) and return unless \
  (SHA1.new(params["pwd"]).to_s == "9fdb1a12b37c7b0efc28276fce277e957ebd034f" or dev_env?)
  
  unless params["migration"].nil?
    if Devtools.migrations.singleton_methods.include? params["migration"]
      Devtools.migrations.send(params["migration"].to_sym)
      halt haml "%h2 Migration #{params["migration"]} done."
    else
      halt haml "%h2 Migration #{params["migration"]} is unknown."
    end
  end
  
  case params["operation"].upcase
  when "RESET":
    halt haml "%h2 Resets are only allowed in development." unless dev_env?
    DataMapper.auto_migrate!
    halt haml "%h2 Database reset completed"
  when "ADD DEV DATA":
    halt haml "%h2 Loading dev data is only allowed in development."  unless dev_env?
    Devtools.load_dev_data
    halt haml "%h2 Dev Data Loaded"
  end unless params["operation"].nil?
  
  unless params["delete"].nil?
    sha1 = params["delete"]
    audition = Audition.first(:sha1 => sha1)
    halt haml "%h2 Audition with sha1 #{sha1} was not found." if audition.nil?
    
    audition.destroy
    halt haml "%h2 #{audition.title} (#{sha1}) was destroyed forever."
  end
  haml "%h2 Your request was malformed (check spelling of operation)"  
end  
