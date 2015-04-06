describe "Application 'Hello'" do
  before do
    @app = UIApplication.sharedApplication
  end

  # it "has one window" do
  #   @app.windows.size.should == 1
  # end    
end

describe "Mod" do
  before do
    @mod = Mod['acura ilx 2012 sedan 2.4i-201ps-MT-FWD']
  end
  
  it "#consumption_string" do
    Disk.unitSystem = 'SI'
    @mod.consumption_string.should == "L / 100 km\n10.7 / 7.6 / 9.4"
  end
end
