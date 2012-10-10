describe "ModSet" do
  before do
    @app = UIApplication.sharedApplication

    @modKeys = [
      "ford mondeo 2010 hatch_5d 2.0i-145ps-MT-FWD",
      "mercedes_benz e 2009 sedan 3.5i-292ps-AT-RWD",
      "volkswagen passat 2011 wagon 2.0i-210ps-AMT-FWD"
    ]

    ModSet.deleteAll
    @set1 = ModSet.create(name: "set 1")
    @set2 = ModSet.create(name: "set 2")
    @set3 = ModSet.create(name: "set 3", modKeysString:@modKeys.join(','))
  end

  it "search by name" do
    result = ModSet.byName("set 2")
    result.should == @set2
    result.name.should == "set 2"
  end
  
  it "modKeys & mods" do
    @set3.modKeys.count.should == 3
    @set3.mods.count.should == 3
    @set3.mods.first.should == Modification.by(@modKeys.first)
    @set3.mods.last.should == Modification.by(@modKeys.last)
    
    @set2.modKeys.should == []
    @set2.mods.should == []
  end

  it "mods=" do
    @set2.mods = ["skoda superb 2008 sedan 2.0d-170ps-AMT-FWD", "citroen c5 2007 sedan 2.0i-143ps-AT-FWD"].map { |key| Modification.by(key) }
    @set2.mods.first.should == Modification.by("skoda superb 2008 sedan 2.0d-170ps-AMT-FWD")
    @set2.mods.last.should == Modification.by("citroen c5 2007 sedan 2.0i-143ps-AT-FWD")
    @set2.modKeysString.should == "skoda superb 2008 sedan 2.0d-170ps-AMT-FWD,citroen c5 2007 sedan 2.0i-143ps-AT-FWD"
  end
  
  it "deleteMod" do
    @set3.deleteMod(Modification.by("mercedes_benz e 2009 sedan 3.5i-292ps-AT-RWD"))
    @set3.mods.count.should == 2
    @set3.modKeysString.should == "ford mondeo 2010 hatch_5d 2.0i-145ps-MT-FWD,volkswagen passat 2011 wagon 2.0i-210ps-AMT-FWD"
  end

  it "swapMods" do
    @set3.swapMods(0, 2)
    @set3.mods.count.should == 3
    @set3.mods.first.should == Modification.by(@modKeys.last)
    @set3.mods.last.should == Modification.by(@modKeys.first)
  end
  
  def ok
    true.should == true
  end
end
