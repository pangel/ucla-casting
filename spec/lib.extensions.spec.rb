require 'pathname'

# See http://avdi.org/devblog/2009/03/02/smart-requires-in-ruby/
# Also http://opensoul.org/2008/1/9/ruby-s-require-doesn-t-expand-paths
require File.expand_path(File.dirname(__FILE__) + '/../lib/extensions.rb')

require 'rubygems'
require 'testy'

module Testy
  class Test
    class Result
      def c(*args)
        check :returned, *args
      end
    end
  end
end 

Testy.testing 'the to_delay method of Time::Class' do
  
  # Test setup
  require 'time' # Need to call Time.parse
  @reference = Time.parse "2008-01-01 1:15pm" #That is Tue Jan 01 13:15:00 -0800 2008
  
  test 'in the past' do |r|
    yesterday = @reference - (3600*24)
    r.c :expect => "Too late", :actual =>yesterday.to_delay(:now => @reference)
  end 
  test '1 second ago' do |r|
    one_sec_ago = @reference - 1
    r.c :expect => "Today", :actual => one_sec_ago.to_delay(:now => @reference)
  end
  
  test 'in 1 second' do |r|
    in_one_sec = @reference + 1
    r.c :expect => "Today", :actual => in_one_sec.to_delay(:now => @reference)
  end
  
  test 'tomorrow' do |r|
    tomorrow = @reference + (3600*24)
    r.c :expect => "Tomorrow", :actual => tomorrow.to_delay(:now => @reference)
  end
  
  test 'this week' do |r|
    this_week = @reference + (3600*24*2)
    r.c :expect => "This week", :actual => this_week.to_delay(:now => @reference)
  end
  
  test 'next week' do |r|
    next_week = @reference + (3600*24*8)
    r.c :expect => "Next week", :actual => next_week.to_delay(:now => @reference)
  end
  
  test 'this month' do |r|
    this_month = @reference + (3600*24*14)
    r.c :expect => "This month", :actual => this_month.to_delay(:now => @reference)
  end
  
  test 'next month' do |r|
    next_month = @reference + (3600*24*31)
    r.c :expect => "Next month", :actual => next_month.to_delay(:now => @reference)
  end
  
end