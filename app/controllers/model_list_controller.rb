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
      @oldDataSources = nil if @oldDataSources
    end

    activeTableView = searchDisplayController.isActive ? searchDisplayController.searchResultsTableView : tableView
    activeTableView.reloadVisibleRows
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
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

    oldCategory = @category
    @category = newCategory

    if newCategory
      @categoryDataSource = FlatModelsDataSource.new(self, category.models, category) if newCategory != oldCategory
    else
      @categoryDataSource = nil      
    end    
  end
  
  def categoryDataSource
    @categoryDataSource
  end
  
  def currentDataSource
    categoryDataSource || mainDataSource
  end

  def mainDataSource
    @mainDataSource ||= SectionedModelsDataSource.new(self)
  end

  def viewSelectorBarItem
    @viewSelectorBarItem ||= KK.textBBI(currentTitle, target:self, action:'showCategories')
  end
    
  def categoriesController
    @categoriesController ||= ModelCategoriesController.new
  end
  
  
  def showCategories
    presentNavigationController categoriesController, presentationStyle:UIModalPresentationCurrentContext
  end
end
