class ModificationSetsController < UITableViewController
  attr_accessor :sets

  def initialize(sets = ModificationSet.all)
    init
    @sets = sets
  end

  def viewDidLoad
    super
    self.title = "Model Sets"
  end
  
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    @sets.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    cell = tv.dequeueReusableCell { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
    cell.textLabel.text = set.name
    cell
  end

  # def tableView(tv, didSelectRowAtIndexPath:indexPath)
  #   tv.deselectRowAtIndexPath(indexPath, animated:true)
  # 
  #   bodyKey = modsByBody.keys[indexPath.section]
  #   mod = modsByBody[bodyKey][indexPath.row]
  #   Disk.toggleModInCurrentList(mod)
  # 
  #   cell = tv.cellForRowAtIndexPath(indexPath)
  #   cell.toggleCheckmarkAccessory
  # end
end
