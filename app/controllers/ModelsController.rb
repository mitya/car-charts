class ModelsController < UITableViewController
  attr_accessor :category
  
  def initialize(models)
    @initialModels = models
    self.title = "Models"
  end

  def viewDidLoad
    @filteredModels = @initialModels
    
    @searchBar = UISearchBar.alloc.initWithFrame(CGRectMake(0, 0, 320, 44))
    @searchBar.autocorrectionType = UITextAutocorrectionTypeNo
    @searchBar.placeholder = "Search"
    @searchBar.delegate = self
    tableView.tableHeaderView = @searchBar
    tableView.contentOffset = CGPointMake(0, @searchBar.frame.height)
    tableView.addSubview ES.grayTableViewTop
    
    @searchController = UISearchDisplayController.alloc.initWithSearchBar(@searchBar, contentsController:self)
    @searchController.delegate = @searchController.searchResultsDataSource = @searchController.searchResultsDelegate = self    
    
    navigationItem.backBarButtonItem = ES.textBBI("Back")
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  ####

  def tableView(tv, numberOfRowsInSection:section)
    @filteredModels.count
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)  
    model = @filteredModels[indexPath.row]
    modelSelectedModsCount = model.selectedModsCount

    cell = table.dequeueReusableCell(klass: DSBadgeViewCell) { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
    cell.text = model.name
    cell.badgeText = modelSelectedModsCount.to_s if modelSelectedModsCount > 0
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    model = @filteredModels[indexPath.row]
    tableView.deselectRowAtIndexPath indexPath, animated:YES
    navigationController.pushViewController ModsController.new(model), animated:YES
  end
  
  ####
  
  def searchDisplayController(controller, shouldReloadTableForSearchString:newSearchString)
    currentModels = @filteredModels
    ES.benchmark "Model Search" do
      collectionToSearch = newSearchString.start_with?(@currentSearchString) ? @filteredModels : @initialModels
      @filteredModels = newSearchString.empty? ? @initialModels : Model.modelsForText(newSearchString, inCollection:collectionToSearch)
    end
    currentModels != @filteredModels
  end
end
