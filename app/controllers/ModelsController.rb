class ModelsController < UITableViewController
  attr_accessor :models, :searchBar

  def viewDidLoad
    super
    self.title = "Car Models"

    @filteredModels = @models.dup
    
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
    @filteredModels.count
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    model = @filteredModels[indexPath.row]
    modelSelectedModsCount = model.selectedModsCount

    cell = table.dequeueReusableCell(klass: BadgeViewCell)
    cell.textLabel.text = model.name || model.key
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.badgeText = modelSelectedModsCount.to_s if modelSelectedModsCount > 0
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    model = @filteredModels[indexPath.row]

    controller = ModificationsController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.model = model
    navigationController.pushViewController(controller, animated:true)
  end
  
  def scrollViewWillBeginDragging(scrollView)
    searchBar.resignFirstResponder
  end
  
  def searchBar(sb, textDidChange:text)
    text.empty? ? 
      @filteredModels = @models.dup :
      @filteredModels = @models.select { |model| model.name =~ /\b#{text.downcase}/i }
    tableView.reloadData
  end
end
