class ModificationSetController < UITableViewController
  attr_accessor :set

  def initialize(set)
    @set = set
  end

  def viewDidLoad
    super
    self.title = set.name
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
    cell = tv.dequeueReusableCell { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
    cell.textLabel.text = mod.nameWithVersion
    cell
  end

  # def tableView(tv, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
  #   if editingStyle == UITableViewCellEditingStyleDelete
  #     set = @sets[indexPath.row]
  #     set.delete
  #     reloadSets
  #     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
  #   end 
  # end
end
