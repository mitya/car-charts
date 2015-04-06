# Represents a category of models, e.g. 'E class'.
class ModelCategoriesController < UITableViewController
  attr_accessor :category
  attr_accessor :segmentedControl
  attr_accessor :mode

  MODES = [:categories, :brands]

  def initialize
    self.title = "Categories"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("ti-car"), tag:3)
    self.navigationItem.leftBarButtonItem = KK.textBBI('All', target:self, action:'showAll')
    self.navigationItem.rightBarButtonItem = KK.imageBBI('bar-xb', target:self, action:'close')
    self.mode = :brands
  end

  def viewWillAppear(animated) super
    tableView.reloadData # refresh badges

    tableView.dataSource = currentDataSource
    tableView.delegate = currentDataSource
  end

  def viewDidLoad
    @segmentedControl ||= UISegmentedControl.alloc.initWithItems(%w(Categories Brands)).tap do |control|
      control.segmentedControlStyle = UISegmentedControlStyleBar
      control.addTarget self, action:'switchView', forControlEvents:UIControlEventValueChanged
      control.selectedSegmentIndex = 1
    end
    navigationItem.titleView = segmentedControl
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end

  def currentDataSource
    case mode when :categories
      @categoriesDS ||= CategoriesDataSource.new(self, category, Category.allSortedByName)
    when :brands
      @brandsDS ||= CategoriesDataSource.new(self, category, Brand.allSortedByName)
    end
  end

  def switchView
    @mode = MODES[segmentedControl.selectedSegmentIndex]
    tableView.dataSource = tableView.delegate = currentDataSource

    tableView.reloadData
  end

  def close
    dismissSelfAnimated
  end
  
  def showAll
    self.category = nil
    close
  end

  class CategoriesDataSource
    attr_accessor :category, :controller, :source

    def initialize(controller, category, source)
      @controller, @category, @source = controller, category, source
    end

    def tableView(tableView, numberOfRowsInSection:section)
      source.count
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)
      cell = tableView.dequeueReusableCell(style: UITableViewCellStyleValue1)
      rowCategory = source[indexPath.row]
      cell.textLabel.text = rowCategory.name
      cell.detailTextLabel.text = rowCategory.selectedModsCount.to_s_or_nil
      cell.accessoryType = rowCategory == category ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      tableView.deselectRowAtIndexPath(indexPath, animated:true)
      controller.category = self.category = source[indexPath.row]
      tableView.visibleCells.each { |c| c.accessoryType = UITableViewCellAccessoryNone }
      cell = tableView.cellForRowAtIndexPath(indexPath)
      cell.accessoryType = UITableViewCellAccessoryCheckmark
      controller.close
    end
  end
end
