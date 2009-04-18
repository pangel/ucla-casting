class Audition
  include DataMapper::Resource
  
  attr_accessor :when_time, :when_date
  
  property :id, Serial
  property :title, String, :length => 80, :nullable => false, :default => ""
  property :when, Time, :nullable => false, :default => Time.local(Time.now.year, Time.now.month, Time.now.mday, 7, 30)
  property :where, String, :nullable => false, :default => ""
  property :description, Text, :nullable => false, :default => ""
  property :sha1, String, :length => 128, :unique => true, :default => Proc.new { |r, p| checksum(r)}
  property :email, String, :nullable => true, :default => ""
  property :pwd, String, :length => 128, :nullable => true, :default => ""
  
  after :create do
    self.sha1 = self.class.checksum(self)
  end

  before :update do
     self.pwd = SHA1.new(self.pwd) unless self.pwd.blank?
     self.sha1 = self.class.checksum(self)
  end
  
  before :save do
    require 'sha1'
    self.pwd = SHA1.new(self.pwd) unless self.pwd.blank?
    self.when = Time.parse("#{self.when_date} #{self.when_time}")
    self.sha1 = self.class.checksum(self)
    %w[description where title email].each { |m| Sanitize.clean!(self.send(m)) }
  end
    
  def self.checksum(r)
    require 'sha1'
    blob = r.title + r.when.to_s + r.where + r.description
    SHA1.new(blob).to_s
  end
  
  def self.clean_new(params)
    self.new(clean_params params)
  end
  
  def clean_change(params)
    self.attributes = (self.class.clean_params params)
  end
  
  private
  def self.clean_params(params)
    auth_keys = %w[when_date when_time description where title email pwd]
    params.delete_if { |k,v| not auth_keys.include? k.to_s }
  end
end

