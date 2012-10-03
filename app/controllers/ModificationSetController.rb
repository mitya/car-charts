class ModificationSetController < UITableViewController
  attr_accessor :set

  def initialize(set)
    @set = set
  end

  def viewDidLoad
    super
    self.title = set.name
    self.toolbarItems = [
      Hel.systemBBI(UIBarButtonSystemItemFlexibleSpace),      
      Hel.textBBI("Replace Selected", target:self, action:'replaceCurrent'),
      Hel.systemBBI(UIBarButtonSystemItemFlexibleSpace),      
      Hel.textBBI("Add to Selected", target:self, action:'addToCurrent'),
      Hel.systemBBI(UIBarButtonSystemItemFlexibleSpace)
    ]
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  ####

  def tableView(tv, numberOfRowsInSection:section)
    @set.mods.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    mod = @set.mods[indexPath.row]
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleSubtitle) { |cl| cl.selectionStyle = UITableViewCellSelectionStyleNone }
    cell.textLabel.text = mod.model.name
    cell.detailTextLabel.text = mod.mod_name
    cell
  end
  
  ####
  
  def replaceCurrent
    @set.replaceCurrentMods
  end
  
  def addToCurrent
    @set.addToCurrentMods
  end
end