class CategoriesController < UITableViewController
  def initialize
    self.title = "Model Categories"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Categories", image:UIImage.imageNamed("ico-tbi-car"), tag:3)
  end

  def viewDidLoad
    navigationItem.backBarButtonItem = ES.textBBI("Back")
  end
  
  def viewWillAppear(animated)
    super
    tableView.reloadData # refresh badges
  end
  
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    Metadata.categoryKeys.count
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    categoryKey = Metadata.categoryKeys[indexPath.row]
    categorySelectedModsCount = Disk.currentMods.select { |mod| mod.category.to_sym == categoryKey }.count

    cell = table.dequeueReusableCell(klass: DSBadgeViewCell) { |cell| cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
    cell.textLabel.text = Metadata.categoryNames[categoryKey]
    cell.badgeText = categorySelectedModsCount
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    categoryKey = Metadata.categoryKeys[indexPath.row]
    controller = ModelsController.new(Model.modelsForCategoryKey(categoryKey))
    controller.categoryKey = categoryKey

    navigationController.pushViewController(controller, animated:true)
  end
end
