class ModelsController < UITableViewController
  def initialize(models)
    @initialModels = models
  end

  def viewDidLoad
    super
    
    self.title = "Car Models"

    isAllModelsView = @initialModels == Make.all
    @initialModelsIndex = isAllModelsView ? Make.indexByBrand : @initialModels.indexBy(&:brandKey)
    @initialBrandKeys = isAllModelsView ? Metadata.brandKeys : @initialModelsIndex.keys.sort
    @models = @initialModels
    @modelsIndex = @initialModelsIndex
    @brandKeys = @initialBrandKeys
    
    @searchBar = UISearchBar.alloc.initWithFrame(CGRectMake(0, 0, 320, 45))
    @searchBar.autocorrectionType = UITextAutocorrectionTypeNo
    @searchBar.placeholder = "Search"
    @searchBar.delegate = self
    tableView.tableHeaderView = @searchBar
    
    @searchController = UISearchDisplayController.alloc.initWithSearchBar(@searchBar, contentsController:self)
    @searchController.delegate = @searchController.searchResultsDataSource = @searchController.searchResultsDelegate = self
  end

  def numberOfSectionsInTableView(tv)
    @brandKeys.count
  end

  def tableView(tv, titleForHeaderInSection:section)
    brandKey = @brandKeys[section]
    Metadata.brandNames[brandKey]
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    brandKey = @brandKeys[section]
    @modelsIndex[brandKey].count
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    brandKey = @brandKeys[indexPath.section]
    model = @modelsIndex[brandKey][indexPath.row]
    modelSelectedModsCount = model.selectedModsCount

    cell = table.dequeueReusableCell(klass: BadgeViewCell)
    cell.textLabel.text = model.unbrandedName
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.badgeText = modelSelectedModsCount.to_s if modelSelectedModsCount > 0
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)

    brandKey = @brandKeys[indexPath.section]
    model = @modelsIndex[brandKey][indexPath.row]

    controller = ModificationsController.new
    controller.model = model
    navigationController.pushViewController(controller, animated:YES)
  end
  
  def sectionIndexTitlesForTableView(tv)
    [UITableViewIndexSearch] + @brandKeys.map { |bk| Metadata.brandNames[bk].chr }.uniq    
  end
  
  def tableView(tableView, sectionForSectionIndexTitle:letter, atIndex:index)
    tableView.scrollRectToVisible(@searchBar.frame, animated:NO) and return -1 if letter == UITableViewIndexSearch
    @brandKeys.map { |bk| Metadata.brandNames[bk] }.index { |name| name.chr == letter }
  end  
  
  def searchDisplayController(controller, shouldReloadTableForSearchString:newSearchString)
    currentModels = @models
    
    if newSearchString.empty?
      @models = @initialModels
      @modelsIndex = @initialModelsIndex
      @brandKeys = @initialBrandKeys
    else
      Helper.benchmark "Model Search" do
        regex = /\b#{newSearchString.downcase}/i
        collectionForSearch = newSearchString.start_with?(@currentSearchString) ? @models : @initialModels
        @models = collectionForSearch.select { |model| model.name =~ regex }
        @modelsIndex = @models.indexBy(&:brandKey)
        @brandKeys = @modelsIndex.keys.sort
      end
    end
    @currentSearchString = newSearchString
    
    currentModels != @models
  end
end
