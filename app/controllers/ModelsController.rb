class ModelsController < UITableViewController
  attr_accessor :models, :searchBar

  def viewDidLoad
    super
    self.title = "Car Models"

    @filteredModels = @models
    
    self.searchBar = UISearchBar.alloc.initWithFrame(CGRectMake(0, 0, 320, 45))
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo
    searchBar.placeholder = "Search"
    searchBar.delegate = self
    tableView.tableHeaderView = searchBar
    
    searchController = UISearchDisplayController.alloc.initWithSearchBar(searchBar, contentsController:self)
    searchController.delegate = self
    searchController.searchResultsDataSource = self
    searchController.searchResultsDelegate = self    
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

    controller = ModificationsController.new
    controller.model = model
    navigationController.pushViewController(controller, animated:true)
  end
  
  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    previousFilteredModels = @filteredModels
    @filteredModels = searchString.empty? ? 
      @models :
      @models.select { |model| model.name =~ /\b#{searchString.downcase}/i }
    previousFilteredModels != @filteredModels
  end
end
