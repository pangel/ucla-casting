# Monkey patches
class Time
  def to_delay(options = {})
    now = options[:now] || options['now'] || Time.now
    # Process the duration between two dates in natural language.
    # _self_ is assumed to be greater than Time.now
    # Contains many unadressed edge cases: last day of week, last day of month, last day of year ...
     
    if self.yday == now.yday
      "Today"
    elsif self < now
      "Too late"
    elsif self.yday == now.yday+1 and self.year == now.year
      "Tomorrow"
    elsif self.strftime("%W").to_i == now.strftime("%W").to_i and self.year == now.year
      "This week"
    elsif self.strftime("%W").to_i == now.strftime("%W").to_i+1 and self.year == now.year
      "Next week"
    elsif self.month == now.month and self.year == now.year
      "This month"
    elsif self.month == now.month+1 and self.year == now.year
      "Next month"
    else
      "Later"
    end
  end
end

class String
  def nl2br
    self.gsub(/\n/, '<br>')
  end
end

class Fixnum    
  # Returns a string of the integer prefixed with zeros. 
  # Enough zeros will be added so as to make a string that is _characters_ long.
  def width(characters)
    "0"*(characters - self.to_s.size) + self.to_s
  end
end

class Hash
  # Applies a given block to all values of _self_. Returns the new _self_.
  def map_values! &block
    each_pair { |k,v| store(k,block.call(v)) }
  end
end

# Helper modules

module DevelopmentHelpers
  # Console output functions (aid for development)
  def blue(string)
    puts "\n\e[0;34m #{string} \e[m\n\n"
  end

  def green(string)
    puts "\n\e[0;32m #{string} \e[m\n\n"
  end
end

module Helpers
  # Convenience method
  def times_of_day
    TIMES_OF_DAY
  end
  
  def dev_env?
    options.environment  === :development
  end
  
  def define_flashes params
    %w[created edited duplicate error feedback_success feedback_failure feedback_blank deleted].each do |f|
      instance_variable_set("@#{f}".to_sym, true) if params.has_key? f
    end
  end
  
  def authenticate!(sha1,pwd,email)
      halt 404, "Not Found. Mis-typed the link?" unless sha1 && audition = Audition.first(:sha1 => sha1)
      halt 401, "Not authorized. Wrong email/password?." unless audition.pwd == SHA1.new(pwd).to_s && audition.email == email
      return audition
  end

  def notify(audition,password)
    body = <<-EOS
    Your audition for #{audition.title.upcase} was successfully created.
  
    You can view it on #{SITE_URL}
  
    If you wish to modify your audition, follow this link #{SITE_URL}/edit?id=#{audition.sha1}
      
    You will need the following credentials:
    email #{audition.email}
    password #{password}
  
    Important: If you set your audition to a date earlier than today, it will disappear from the front page. Your only way to bring it back up will be to use the link given above, so keep this email!
    EOS
  
    begin
      Pony.mail :to => audition.email, :subject => "Your audition was successfully created on UCLA Casting", :body => body, :via => :smtp, :smtp => SMTP_SETTINGS
    rescue
      puts "NOTIFY SENDING FAILED: " + $!
    end
  end
end
