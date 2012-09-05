class ModelsController < UITableViewController
  attr_accessor :model_keys, :searchBar

  def viewDidLoad
    super
    self.title = "Car Models"

    @filteredModelKeys = @model_keys.dup
    
    self.searchBar = UISearchBar.alloc.initWithFrame(CGRectMake(0, 0, 320, 45))
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo
    searchBar.placeholder = "Search"
    searchBar.delegate = self
    searchBar.sizeToFit
    tableView.tableHeaderView = searchBar
  end

  def viewWillAppear(animated)
    super
    tableView.reloadData
  end

  def tableView(tv, numberOfRowsInSection:section)
    @filteredModelKeys.count
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    model_key = @filteredModelKeys[indexPath.row]
    model_name = Model.model_names_branded[model_key] || model_key
    model_selected_mods_count = Model.current_mods.map(&:model_key).select{ |key| key == model_key}.count

    cell = table.dequeueReusableCell(klass: BadgeViewCell)
    cell.textLabel.text = model_name
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.badgeText = model_selected_mods_count.to_s if model_selected_mods_count > 0
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    model_key = @filteredModelKeys[indexPath.row]

    controller = ModificationsController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.model_key = model_key
    navigationController.pushViewController(controller, animated:true)
  end
  
  def scrollViewWillBeginDragging(scrollView)
    searchBar.resignFirstResponder
  end
  
  def searchBar(sb, textDidChange:text)
    if text.empty?
      @filteredModelKeys = @model_keys.dup 
    else
      @filteredModelKeys = @model_keys.select { |k| title = k.split(/--?|_/).join(' '); title =~ /\b#{text.downcase}/ }
    end
    tableView.reloadData
  end
end
