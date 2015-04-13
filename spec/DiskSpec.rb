describe "Disk" do
  before do
    NSUserDefaults.standardUserDefaults["favorites"] = nil
  end

  it "favorites are initially empty" do
    Disk.favorites.should == []
  end
  
  it "adding and removing keys keys in favorites" do
    Disk.toggleInFavorites "bmw--3er--2011"
    Disk.favorites.should == ["bmw--3er--2011"]
    
    Disk.toggleInFavorites "audi--a4--2011"
    Disk.favorites.should == ["bmw--3er--2011", "audi--a4--2011"]
    
    Disk.toggleInFavorites "bmw--3er--2011"
    Disk.favorites.should == ["audi--a4--2011"]

    Disk.toggleInFavorites "audi--a4--2011"
    Disk.favorites.should == []
  end
  
  it 'default unit system is SI' do    
    Disk.unitSystem.should == 'SI'
  end
end
