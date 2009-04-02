class Audition
  include DataMapper::Resource
 
  property :id, Serial
  property :title, String
  property :when, Time
  property :where, String
  property :description, Text
 
  # validates_present :name
end