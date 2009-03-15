class Devtools
  def self.load_dev_data
    myrevenge = Audition.new
    myrevenge.attributes = {:title => "My Revenge", :when => Time.local(2009, 04, 01, 13, 30, 00), :where => "Soundstage 2", :description => "Blablabla \n Hohoho"}
    myrevenge.save

    thebox = Audition.new
    thebox.attributes = {:title => "The Box", :when => Time.local(2009, 04, 03, 15, 15, 00), :where => "Soundstage 1", :description => "Ceci est \n la description de boite"}
    thebox.save
  end
end