class ModificationsController < UITableViewController
  attr_accessor :model_key, :mods, :mods_by_body
  
  def viewDidLoad
    super
    self.title = "Modifications"
    @mods = Model.modifications_by_model_key[@model_key]
    @mods_by_body = @mods.group_by { |m| m.body }
  end  

  def numberOfSectionsInTableView tview
    mods_by_body.count
  end

  def tableView tview, numberOfRowsInSection:section
    body_key = mods_by_body.keys[section]
    mods_by_body[body_key].count
  end

  def tableView tview, titleForHeaderInSection:section
    body_key = mods_by_body.keys[section]    
    Model.metadata['body_names'][body_key]    
  end

  def tableView table, cellForRowAtIndexPath:indexPath
    body_key = mods_by_body.keys[indexPath.section]
    mod = mods_by_body[body_key][indexPath.row]

    cell = table.dequeueReusableCell
    cell.textLabel.text = mod.full_name
    cell.accessoryType = Model.current_mod_keys.include?(mod.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView table, didSelectRowAtIndexPath:indexPath
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  
    body_key = mods_by_body.keys[indexPath.section]
    mod = mods_by_body[body_key][indexPath.row]
    
    cell = tableView.cellForRowAtIndexPath(indexPath)
    if cell.toggleCheckmark
      Model.current_mod_keys = Model.current_mod_keys - [mod.key]
    else
      Model.current_mod_keys = Model.current_mod_keys + [mod.key]
    end
  end
end
