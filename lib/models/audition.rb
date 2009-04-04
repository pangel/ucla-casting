class Audition
  include DataMapper::Resource
 
  property :id, Serial
  property :title, String
  property :when, Time
  property :where, String
  property :description, Text
  property :sha1, String, :length => 128, :unique => true, :default => Proc.new { |r, p| checksum(r)}

  def self.checksum(r)
    require 'sha1'
    blob = r.title + r.when.to_s + r.where + r.description
    SHA1.new blob
  end
  
  # validates_present :name
end

