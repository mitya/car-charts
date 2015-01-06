class ModelsController < UIViewController
  attr_accessor :searchBar, :tableView
  attr_accessor :category, :currentDataSource
  
  def initialize
    self.title = "Models"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:UIImage.imageNamed("ico-tbi-car-1"), tag:3)

    self.navigationItem.titleView = UIView.alloc.init
    self.navigationItem.rightBarButtonItems = [KK.flexibleSpaceBBI, viewSelectorBarItem, KK.flexibleSpaceBBI]
  end
  
  def viewDidLoad
    self.tableView = setupTableViewWithStyle(UITableViewStylePlain)
    tableView.addSubview KK.tableViewGrayBackground

    self.searchBar = UISearchBar.alloc.init
    searchBar.frame = CGRectMake(0, 0, 0, UIToolbarHeight)
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth
    searchBar.placeholder = "Search"
    
    self.searchDisplayController = UISearchDisplayController.alloc.initWithSearchBar(searchBar, contentsController:self)
  end

  def viewWillAppear(animated)
    super
    
    searchBar.frame = CGRectMake(0, 0, view.bounds.width, UIToolbarHeight)
    
    activeTableView = searchDisplayController.isActive ? searchDisplayController.searchResultsTableView : tableView
    activeTableView.reloadVisibleRows

    self.category = categoriesController.category if @categoriesController
        
    navigationItem.title = viewSelectorBarItem.title = currentTitle
    navigationItem.backBarButtonItemTitle = currentShortTitle

    if tableView.dataSource != currentDataSource || searchDisplayController.searchResultsDataSource != currentDataSource
      tableView.dataSource = currentDataSource
      tableView.delegate = currentDataSource
      searchBar.delegate = currentDataSource
      searchDisplayController.delegate = currentDataSource
      searchDisplayController.searchResultsDataSource = currentDataSource
      searchDisplayController.searchResultsDelegate = currentDataSource
      tableView.reloadData
      tableView.tableHeaderView = nil
      tableView.tableHeaderView = searchBar      
      tableView.contentOffset = currentDataSource == mainDataSource ? CGPointMake(0, 0) : CGPointMake(0, UIToolbarHeight)
    end
  end



  def currentTitle
    category ? category.name : "All Models"
  end
  
  def currentShortTitle
    category ? category.shortName : "All"
  end
  
  def currentDataSource
    if category == nil
      mainDataSource
    else
      if @categoryDataSource && @categoryDataSource.category == category
        @categoryDataSource
      else
        @categoryDataSource = FlatModelsDataSource.new(self, category.models, category)
      end      
    end
  end

  def mainDataSource
    @mainDataSource ||= SectionedModelsDataSource.new(self)
  end

  def viewSelectorBarItem
    @viewSelectorBarItem ||= KK.textBBI(currentTitle, target:self, action:'showCategories')
  end
    
  def categoriesController
    @categoriesController ||= CategoriesController.new
  end
  
  def showCategories
    presentNavigationController categoriesController, presentationStyle:UIModalPresentationCurrentContext
  end
  

  
  class SectionedModelsDataSource
    attr_accessor :controller, :models, :category
    
    def initialize(controller, models = Model.all)
      @controller = controller
      @initialModels = models
      @isAllModelsView = models == Model.all
      @initialModelsIndex = @isAllModelsView ? Model::IndexByBrand.new : @initialModels.indexBy { |m| m.brand.key }
      @initialBrands = @isAllModelsView ? Brand.all : @initialModelsIndex.keys.sort.map { |k| Brand[k] }
      @models, @modelsIndex, @brands = @initialModels, @initialModelsIndex, @initialBrands
    end
    
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
      @modelsIndex[@brands[indexPath.section].key][indexPath.row]
      model = @modelsIndex[@brands[indexPath.section].key][indexPath.row]
      modelSelectedModsCount = model.selectedModsCount

      cell = table.dequeueReusableCell(klass: KKBadgeViewCell) { |cell| cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
      cell.textLabel.text = model.unbrandedName
      cell.badgeText = modelSelectedModsCount
      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      model = @modelsIndex[@brands[indexPath.section].key][indexPath.row]
      controller.tableView.deselectRowAtIndexPath indexPath, animated:YES
      controller.navigationController.pushViewController ModsController.new(model), animated:YES
    end
  
    def sectionIndexTitlesForTableView(tv)
      [UITableViewIndexSearch] + @brands.map { |brand| brand.name.chr }.uniq    
    end
  
    def tableView(tableView, sectionForSectionIndexTitle:letter, atIndex:index)
      if letter == UITableViewIndexSearch || letter == 'A'
        tableView.scrollRectToVisible(controller.searchBar.frame, animated:NO)
        return -1
      end
      @brands.index { |brand| brand.name.chr == letter }
    end  
  

  
    def searchDisplayController(ctl, willShowSearchResultsTableView:tbl)
      controller.navigationItem.backBarButtonItem = KK.textBBI("Search")  
    end  
  
    def searchDisplayController(ctl, shouldReloadTableForSearchString:newSearchString)
      @currentModels = @models
      loadDataForSearchString(newSearchString)
      @currentModels != @models
    end
    
    def searchBarCancelButtonClicked(searchBar)
      loadDataForSearchString("")
      controller.tableView.reloadVisibleRows
      controller.navigationItem.backBarButtonItemTitle = controller.currentShortTitle
    end



    def loadDataForSearchString(newSearchString)
      if newSearchString.empty?
        @models, @modelsIndex, @brands = @initialModels, @initialModelsIndex, @initialBrands
      else
        collectionToSearch = newSearchString.start_with?(@currentSearchString) ? @models : @initialModels
        @models = Model.modelsForText(newSearchString, inCollection:collectionToSearch)
        @modelsIndex = @models.indexBy { |ml| ml.brand.key }
        @brands = @modelsIndex.keys.sort.map { |k| Brand[k] }
      end
      @currentSearchString = newSearchString
    end    
  end
  
  
  
  class FlatModelsDataSource
    attr_accessor :controller, :models, :category
    
    def initialize(controller, models, category = nil)
      @controller = controller
      @category = category
      @initialModels = models      
      @filteredModels = @initialModels
    end

    def models=(objects)
      @initialModels = objects
      @filteredModels = @initialModels
    end
    
    def tableView(tv, numberOfRowsInSection:section)
      @filteredModels.count
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)  
      model = @filteredModels[indexPath.row]
      modelSelectedModsCount = model.selectedModsCount

      cell = tableView.dequeueReusableCell(klass:KKBadgeViewCell) { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
      cell.text = model.name
      cell.badgeText = modelSelectedModsCount
      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      model = @filteredModels[indexPath.row]
      tableView.deselectRowAtIndexPath indexPath, animated:YES
      controller.navigationController.pushViewController ModsController.new(model), animated:YES
    end
  


    def searchDisplayController(ctl, willHideSearchResultsTableView:tbl)
      loadDataForSearchString("")
      controller.tableView.reloadVisibleRows
      controller.navigationItem.backBarButtonItemTitle = controller.currentShortTitle
    end
  
    def searchDisplayController(ctl, willShowSearchResultsTableView:tbl)
      controller.navigationItem.backBarButtonItem = KK.textBBI("Search")
    end  
  
    def searchDisplayController(controller, shouldReloadTableForSearchString:newSearchString)
      @currentModels = @filteredModels
      loadDataForSearchString(newSearchString)
      @currentModels != @filteredModels
    end

  
    def loadDataForSearchString(newSearchString)
      collectionToSearch = newSearchString.start_with?(@currentSearchString) ? @filteredModels : @initialModels
      @filteredModels = newSearchString.empty? ? @initialModels : Model.modelsForText(newSearchString, inCollection:collectionToSearch)
      @currentSearchString = newSearchString
    end    
  end
end
