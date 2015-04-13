describe "Disk" do
  before do
    NSUserDefaults.standardUserDefaults["favorites"] = nil
  end

  it "favorites are initially empty" do
    Disk.favorites.should == []
  end
  
  it "adding and removing keys keys in favorites" do
    bmw_3er = ModelGeneration["bmw--3er--2011"]
    audi_a4 = ModelGeneration["audi--a4--2011"]
    
    Disk.toggleInFavorites bmw_3er
    Disk.favorites.should == [bmw_3er]
    
    Disk.toggleInFavorites audi_a4
    Disk.favorites.should == [bmw_3er, audi_a4]
    
    Disk.toggleInFavorites bmw_3er
    Disk.favorites.should == [audi_a4]

    Disk.toggleInFavorites audi_a4
    Disk.favorites.should == []
  end
  
  it 'default unit system is SI' do    
    Disk.unitSystem.should == 'SI'
  end
end
