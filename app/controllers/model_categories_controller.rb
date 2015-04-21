# Represents a category of models, e.g. 'E class'.
class ModelCategoriesController < UITableViewController
  attr_accessor :category
  attr_accessor :segmentedControl
  attr_accessor :mode
  attr_accessor :popover  
  attr_accessor :modelsController  

  MODES = [:brands, :categories]

  def initialize(modelsController)
    self.title = "Categories"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("tab-car"), selectedImage:KK.image("tab-car-full"))    
    self.navigationItem.rightBarButtonItem = KK.imageBBI('bar-x', target:self, action:'close')
    self.mode = :brands
    self.modelsController = modelsController
  end

  def viewWillAppear(animated) super
    tableView.reloadData # refresh badges
    tableView.dataSource = currentDataSource
    tableView.delegate = currentDataSource
  end

  def viewDidLoad
    @segmentedControl ||= UISegmentedControl.alloc.initWithItems(%w(Brands Categories)).tap do |control|
      control.segmentedControlStyle = UISegmentedControlStyleBar
      control.addTarget self, action:'switchView', forControlEvents:UIControlEventValueChanged
      control.selectedSegmentIndex = 0
    end
    navigationItem.titleView = segmentedControl
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0)
    self.preferredContentSize = [320, 700]
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
    KK.trackEvent "categories-brands-switched"
    @mode = MODES[segmentedControl.selectedSegmentIndex]
    tableView.dataSource = tableView.delegate = currentDataSource
    tableView.reloadData
  end

  def close
    dismissSelfAnimated
    if KK.ipad?
      modelsController.category = category
      modelsController.reload 
    end
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
      source.count + 1
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)
      cell = tableView.dequeueReusableCell(style: UITableViewCellStyleValue1)
      
      cell.accessoryType = UITableViewCellAccessoryNone
      
      if indexPath.row == 0
        cell.textLabel.text = "All Models"
        cell.accessoryType = UITableViewCellAccessoryCheckmark if controller.category == nil
        # cell.detailTextLabel.text = ModelGeneration.keys.count.to_s_or_nil
        cell.imageView.image = Brand === source.first ? Brand.unknownBrandImage : nil
      else
        rowCategory = source[indexPath.row - 1]
        cell.textLabel.text = rowCategory.name
        cell.accessoryType = UITableViewCellAccessoryCheckmark if controller.category == rowCategory
        # cell.detailTextLabel.text = rowCategory.models.count.to_s_or_nil
        cell.imageView.image = Brand === rowCategory ? rowCategory.cellImage : nil
      end

      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      tableView.deselectRowAtIndexPath(indexPath, animated:true)
      
      controller.category = self.category = indexPath.row == 0 ? nil : source[indexPath.row - 1]

      tableView.visibleCells.each { |c| c.accessoryType = UITableViewCellAccessoryNone }
      cell = tableView.cellForRowAtIndexPath(indexPath)
      cell.accessoryType = UITableViewCellAccessoryCheckmark

      controller.close
    end
  end
end
