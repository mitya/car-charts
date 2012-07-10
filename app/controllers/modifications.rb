class ModificationsController < UITableViewController
  attr_accessor :model_key, :mods
  
  def viewDidLoad
    super
    self.title = "Modifications"
    @mods = Model.modifications_by_model_key[@model_key]
  end  
  
  def tableView tv, numberOfRowsInSection:section
    @mods.count
  end
  
  def tableView table, cellForRowAtIndexPath:indexPath
    mod = @mods[indexPath.row]

    unless cell = table.dequeueReusableCellWithIdentifier("cell")
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"cell")
    end

    cell.textLabel.text = mod.full_name
    cell.accessoryType = Model.current_mods.include?(mod.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView table, didSelectRowAtIndexPath:indexPath
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  
    cell = tableView.cellForRowAtIndexPath(indexPath)
    mod = @mods[indexPath.row]
    
    if cell.accessoryType == UITableViewCellAccessoryCheckmark
      cell.accessoryType = UITableViewCellAccessoryNone
      Model.current_mod_keys = Model.current_mod_keys - [mod.key]
    else
      cell.accessoryType = UITableViewCellAccessoryCheckmark
      Model.current_mod_keys = Model.current_mod_keys + [mod.key]
    end
  end
end
