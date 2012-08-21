# Represents a list of modifications of one model
class ModificationsController < UITableViewController
  attr_accessor :model_key, :mods, :modsByBody
  
  def viewDidLoad
    super
    self.title = "Modifications"
    @mods = Model.modifications_by_model_key[@model_key].sort_by { |m| m.key }
    @modsByBody = @mods.group_by { |m| m.body }
  end  

  def numberOfSectionsInTableView(tview)
    @modsByBody.count
  end

  def tableView tview, numberOfRowsInSection:section
    bodyKey = modsByBody.keys[section]
    @modsByBody[bodyKey].count
  end

  def tableView(tview, titleForHeaderInSection:section)
    bodyKey = modsByBody.keys[section]
    Static.body_names[bodyKey]
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    bodyKey = modsByBody.keys[indexPath.section]
    mod = modsByBody[bodyKey][indexPath.row]

    cell = table.dequeueReusableCell
    cell.textLabel.text = mod.modNameNoBody
    cell.accessoryType = Model.current_mod_keys.include?(mod.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  
    bodyKey = modsByBody.keys[indexPath.section]
    mod = modsByBody[bodyKey][indexPath.row]
    
    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmark
    Model.toggle_mod_with_key(mod.key)
  end
end
