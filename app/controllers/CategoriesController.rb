class CategoriesController < UITableViewController
  def initialize
    self.title = "Categories"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:UIImage.imageNamed("ico-tbi-car"), tag:3)
  end

  def viewWillAppear(animated)
    super
    tableView.reloadData # refresh badges
  end
  
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    Category.all.count
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    category = Category.all[indexPath.row]
    cell = table.dequeueReusableCell(klass: DSBadgeViewCell) do |cell|
       cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    end
    cell.textLabel.text = category.name
    cell.badgeText = category.selectedModsCount
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    category = Category.all[indexPath.row]
    controller = ModelsController.new(category.models)
    controller.title = category.shortName

    navigationController.pushViewController(controller, animated:true)
  end
end
