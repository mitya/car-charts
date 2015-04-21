# Displays the list of models. There are few variants:
# - all models grouped by make
# - all models withing a category
# - all models matching a search string (either by make or by model name)
# - all models matching a search string within a category
class ModelListController < UIViewController
  attr_accessor :searchBar, :tableView
  attr_accessor :category, :currentDataSource
  
  def initialize
    self.title = "Models"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("tab-car"), selectedImage:KK.image("tab-car-full"))    

    navigationItem.titleView = UIView.alloc.init
    navigationItem.rightBarButtonItems = [KK.flexibleSpaceBBI, viewSelectorBarItem, KK.flexibleSpaceBBI]
  end
  
  def viewDidLoad
    self.tableView = setupInnerTableViewWithStyle(UITableViewStylePlain)
    self.tableView.sectionIndexBackgroundColor = UIColor.clearColor

    self.searchBar = UISearchBar.alloc.init
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth
    searchBar.placeholder = "Search"

    self.searchDisplayController = UISearchDisplayController.alloc.initWithSearchBar(searchBar, contentsController:self)
  end

  def viewWillAppear(animated)
    super
    
    self.category = @categoriesController.category if @categoriesController
    viewSelectorBarItem.title = currentTitle
    navigationItem.backBarButtonItem = KK.textBBI(currentShortTitle)

    reload
    
    unless @setCanDisplayBannerAds
      self.canDisplayBannerAds = KK.app.delegate.showsBannerAds?
      @setCanDisplayBannerAds = YES
    end
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end  

  def reload
    viewSelectorBarItem.title = currentTitle
    navigationItem.backBarButtonItem = KK.textBBI(currentShortTitle)

    if tableView.dataSource != currentDataSource || searchDisplayController.searchResultsDataSource != currentSearchDataSource
      tableView.dataSource = currentDataSource
      tableView.delegate = currentDataSource
      searchBar.delegate = currentSearchDataSource
      searchDisplayController.delegate = currentSearchDataSource
      searchDisplayController.searchResultsDataSource = currentSearchDataSource
      searchDisplayController.searchResultsDelegate = currentSearchDataSource
      tableView.reloadData
      tableView.tableHeaderView = nil
      tableView.tableHeaderView = searchBar
      @oldDataSources = nil if @oldDataSources
    end

    activeTableView = searchDisplayController.isActive ? searchDisplayController.searchResultsTableView : tableView
    activeTableView.contentOffset = CGPointMake(0, searchBar.frame.height) if activeTableView.contentOffset.y == 0
    activeTableView.reloadVisibleRows
  end

  def currentTitle
    (category ? category.name : "All Models") + ' ▾'
  end
  
  def currentShortTitle
    category ? category.shortName : "All"
  end

  def category=(newCategory)
    @oldDataSources ||= []
    @oldDataSources << currentDataSource if currentDataSource
    @oldDataSources << currentSearchDataSource if currentSearchDataSource

    oldCategory = @category
    @category = newCategory

    if newCategory
      if newCategory != oldCategory
        @categoryDataSource = FlatModelsDataSource.new(self, category.models, category)
        @categorySearchDataSource = FlatModelsDataSource.new(self, category.models, category)
      end
    else
      @categoryDataSource = nil      
      @categorySearchDataSource = nil
    end
  end
  
  def categorySearchDataSource
    @categorySearchDataSource
  end
  
  def categoryDataSource
    @categoryDataSource
  end
  
  def currentSearchDataSource
    categorySearchDataSource || mainSearchDataSource
  end
    
  def currentDataSource
    categoryDataSource || mainDataSource
  end

  def mainDataSource
    @mainDataSource ||= SectionedModelsDataSource.new(self)
  end

  def mainSearchDataSource
    @mainSearchDataSource ||= SectionedModelsDataSource.new(self)
  end

  def viewSelectorBarItem
    @viewSelectorBarItem ||= KK.textBBI(currentTitle, target:self, action:'showCategories')
  end
    
  def categoriesController
    @categoriesController ||= ModelCategoriesController.new(self)
  end
  
  
  def showCategories    
    if KK.iphone?
      presentNavigationController categoriesController
    else
      categoriesController.popover = presentPopoverController categoriesController, fromBarItem:viewSelectorBarItem
    end    
  end
end
