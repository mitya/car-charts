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
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("ti-car"), tag:3)

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
    
    activeTableView = searchDisplayController.isActive ? searchDisplayController.searchResultsTableView : tableView
    activeTableView.reloadVisibleRows

    self.category = categoriesController.category if @categoriesController
        
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
      # tableView.contentOffset = CGPointMake(0, 0) # currentDataSource == mainDataSource ? CGPointMake(0, 0) : CGPointMake(0, UIToolbarHeight) # iOS6
    end
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
    @categoriesController ||= ModelCategoriesController.new
  end
  
  def showCategories
    presentNavigationController categoriesController, presentationStyle:UIModalPresentationCurrentContext
  end
end
