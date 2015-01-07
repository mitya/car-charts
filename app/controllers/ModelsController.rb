class ModelsController < UIViewController
  attr_accessor :searchBar, :tableView
  attr_accessor :category, :currentDataSource
  
  def initialize
    self.title = "Models"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("tbi-car-1"), tag:3)

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
end
