class Audition
  include DataMapper::Resource
 
  property :id, Serial
  property :title, String, :length => 80, :nullable => false
  property :when, Time, :nullable => false
  property :where, String, :nullable => false
  property :description, Text, :nullable => false
  property :sha1, String, :length => 128, :unique => true, :default => Proc.new { |r, p| checksum(r)}

  def self.checksum(r)
    require 'sha1'
    blob = r.title + r.when.to_s + r.where + r.description
    SHA1.new blob
  end
  
  def self.create_with(params)
      self.new :when => Time.parse("#{params["when_date"]} #{params["when_time"]}"),
               :description => Sanitize.clean(params["description"]),
               :where => Sanitize.clean(params["where"]),
               :title => Sanitize.clean(params["title"])
  end
end

