class CategoriesController < UITableViewController
  def initialize
    self.title = "Categories"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Cars", image:UIImage.imageNamed("ico-tab-categories.png"), tag:1)    
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

    cell = table.dequeueReusableCell(klass: BadgeViewCell)
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.textLabel.text = Metadata.categoryNames[categoryKey]
    cell.badgeText = categorySelectedModsCount.to_s if categorySelectedModsCount > 0
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    categoryKey = Metadata.categoryKeys[indexPath.row]
    controller = ModelsController.new(Model.byCategoryKey(categoryKey))

    navigationController.pushViewController(controller, animated:true)
  end
end
