class Devtools
  def self.load_dev_data
    myrevenge = Audition.new
    myrevenge.attributes = {:title => "My Revenge", :when => Time.local(2009, 04, 15, 13, 30, 00), :where => "Soundstage 2", :description => "Head must be bald or shaved.\nMust have an interesting voice (you can attach a sound sample).\n\nThe character is mostly a voiceover but throughout the film his silhouette will appear."}
    myrevenge.save

    thebox = Audition.new
    thebox.attributes = {:title => "The Box", :when => Time.local(2009, 06, 03, 15, 15, 00), :where => "Soundstage 1", :description => "The character is homeless but this status is only revealed at the end - he or she looks very poor.\n
Wardrobe: USED CLOTHES - CAN BE PROVIDED."}
    thebox.save
  end
  
  module Migrations
    class << self
      def add_checksums
        unchecked_auditions = Audition.all(:sha1 => nil)
        unchecked_auditions.each { |a|
          a.sha1 = Audition.checksum(a)
          a.save
        }
      end
    end
  end
  
  def self.migrations
    Migrations
  end    
  
end