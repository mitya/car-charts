class RecentModificationsController < UITableViewController
  attr_accessor :current, :recent
  
  def viewDidLoad
    super
    self.title = "Recent Modifications"
  end
  
  def viewWillAppear(animated)
    super
    @current = Model.current_mod_keys.map { |k| Model.modification_for(k) }
    @recent = Model.recent_mod_keys.map { |k| Model.modification_for(k) }    
    tableView.reloadData
  end

  def numberOfSectionsInTableView(tv)
    2
  end

  def tableView(tv, numberOfRowsInSection:section)
    case section
    when 0 then @current.count
    when 1 then @recent.count
    end
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    collection = indexPath.section == 0 ? @current : @recent
    mod = collection[indexPath.row]
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleSubtitle)
    cell.textLabel.text = mod.branded_model_name
    cell.detailTextLabel.text = mod.mod_name
    cell.accessoryType = Model.current_mod_keys.include?(mod.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    collection = indexPath.section == 0 ? @current : @recent
    mod = collection[indexPath.row]
    
    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmark
    Model.toggle_mod_with_key(mod.key)
  end
end
