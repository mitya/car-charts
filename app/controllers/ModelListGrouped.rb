class IndexedModelsController < UIViewController
  attr_accessor :searchBar, :tableView
  
  def initialize(models)
    @initialModels = models
    self.title = "Models"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Models", image:UIImage.imageNamed("ico-tbi-car"), tag:2)
  end

  def viewDidLoad
    isAllModelsView = @initialModels == Model.all
    @initialModelsIndex = isAllModelsView ? Model::IndexByBrand.new : @initialModels.indexBy { |m| m.brand.key }
    @initialBrands = isAllModelsView ? Brand.all : @initialModelsIndex.keys.sort.map { |k| Brand[k] }
    @models, @modelsIndex, @brands = @initialModels, @initialModelsIndex, @initialBrands
    
    self.tableView = setupTableViewWithStyle(UITableViewStylePlain, offset:DSToolbarHeight)
    
    self.searchBar = UISearchBar.alloc.initWithFrame(CGRectMake(0, 0, realWidth, DSToolbarHeight)).tap do |searchBar|
      searchBar.autocorrectionType = UITextAutocorrectionTypeNo
      searchBar.placeholder = "Search"
      searchBar.delegate = self
      view.addSubview searchBar
      tableView.addSubview ES.grayTableViewTop
    end
    
    self.searchDisplayController = UISearchDisplayController.alloc.initWithSearchBar(searchBar, contentsController:self).tap do |sdc|
      sdc.delegate = sdc.searchResultsDataSource = sdc.searchResultsDelegate = self
    end
  end

  def viewWillAppear(animated)
    super
    activeTableView = searchDisplayController.isActive ? searchDisplayController.searchResultsTableView : tableView
    activeTableView.reloadVisibleRows
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

    cell = table.dequeueReusableCell(klass: DSBadgeViewCell) { |cell| cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
    cell.textLabel.text = model.unbrandedName
    cell.badgeText = modelSelectedModsCount
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    model = @modelsIndex[@brands[indexPath.section].key][indexPath.row]
    tableView.deselectRowAtIndexPath indexPath, animated:YES
    navigationController.pushViewController ModsController.new(model), animated:YES
  end
  
  def sectionIndexTitlesForTableView(tv)
    @brands.map { |brand| brand.name.chr }.uniq    
  end
  
  def tableView(tableView, sectionForSectionIndexTitle:letter, atIndex:index)
    @brands.index { |brand| brand.name.chr == letter }
  end  
  
  ####
  
  def searchDisplayController(ctl, willHideSearchResultsTableView:tbl)
    loadDataForSearchString("")
    tableView.reloadVisibleRows
    navigationItem.backBarButtonItem = ES.textBBI(title)
  end
  
  def searchDisplayController(ctl, willShowSearchResultsTableView:tbl)
    navigationItem.backBarButtonItem = ES.textBBI("Search")  
  end  
  
  def searchDisplayController(ctl, shouldReloadTableForSearchString:newSearchString)
    currentModels = @models
    loadDataForSearchString(newSearchString)
    currentModels != @models
  end
  
  ####
  
  def loadDataForSearchString(newSearchString)
    if newSearchString.empty?
      @models, @modelsIndex, @brands = @initialModels, @initialModelsIndex, @initialBrands
    else
      ES.benchmark "Model Search" do
        collectionToSearch = newSearchString.start_with?(@currentSearchString) ? @models : @initialModels
        @models = Model.modelsForText(newSearchString, inCollection:collectionToSearch)
        @modelsIndex = @models.indexBy { |ml| ml.brand.key }
        @brands = @modelsIndex.keys.sort.map { |k| Brand[k] }
      end
    end
    @currentSearchString = newSearchString
  end
end
