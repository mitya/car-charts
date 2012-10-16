class IndexedModelsController < UITableViewController
  def initialize(models)
    @initialModels = models
  end

  def viewDidLoad
    super
    
    self.title = "Models"

    isAllModelsView = @initialModels == Model.all
    @initialModelsIndex = isAllModelsView ? Model::IndexByBrand.new : @initialModels.indexBy { |m| m.brand.key }
    @initialBrands = isAllModelsView ? Brand.all : @initialModelsIndex.keys.sort.map { |k| Brand[k] }
    @models = @initialModels
    @modelsIndex = @initialModelsIndex
    @brands = @initialBrands
    
    @searchBar = UISearchBar.alloc.initWithFrame(CGRectMake(0, 0, 320, 44))
    @searchBar.autocorrectionType = UITextAutocorrectionTypeNo
    @searchBar.placeholder = "Search"
    @searchBar.delegate = self
    tableView.tableHeaderView = @searchBar
    tableView.contentOffset = CGPointMake(0, @searchBar.frame.height)
    tableView.addSubview ES.grayTableViewTop
    
    @searchController = UISearchDisplayController.alloc.initWithSearchBar(@searchBar, contentsController:self)
    @searchController.delegate = @searchController.searchResultsDataSource = @searchController.searchResultsDelegate = self    
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  ####

  def numberOfSectionsInTableView(tv)
    @brands.count
  end

  def tableView(tv, titleForHeaderInSection:section)
    @brands[section].name
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    @modelsIndex[@brands[section].key].count
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)  
    model = @modelsIndex[@brands[indexPath.section].key][indexPath.row]
    modelSelectedModsCount = model.selectedModsCount

    cell = table.dequeueReusableCell(klass: DSBadgeViewCell)
    cell.textLabel.text = model.unbrandedName
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.badgeText = modelSelectedModsCount.to_s if modelSelectedModsCount > 0
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    model = @modelsIndex[@brands[indexPath.section].key][indexPath.row]
    tableView.deselectRowAtIndexPath indexPath, animated:YES
    navigationController.pushViewController ModsController.new(model), animated:YES
  end
  
  def sectionIndexTitlesForTableView(tv)
    [UITableViewIndexSearch] + @brands.map { |brand| brand.name.chr }.uniq    
  end
  
  def tableView(tableView, sectionForSectionIndexTitle:letter, atIndex:index)
    tableView.scrollRectToVisible(@searchBar.frame, animated:NO) and return -1 if letter == UITableViewIndexSearch
    @brands.index { |brand| brand.name.chr == letter }
  end  
  
  ####
  
  def searchDisplayController(controller, shouldReloadTableForSearchString:newSearchString)
    currentModels = @models
    
    if newSearchString.empty?
      @models = @initialModels
      @modelsIndex = @initialModelsIndex
      @brands = @initialBrands
    else
      ES.benchmark "Model Search" do
        collectionToSearch = newSearchString.start_with?(@currentSearchString) ? @models : @initialModels
        @models = Model.modelsForText(newSearchString, inCollection:collectionToSearch)
        @modelsIndex = @models.indexBy { |ml| ml.brand.key }
        @brands = @modelsIndex.keys.sort.map { |k| Brand[k] }
      end
    end
    @currentSearchString = newSearchString
    
    currentModels != @models
  end
end
