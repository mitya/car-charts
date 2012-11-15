class CategoriesController < UITableViewController
  attr_accessor :category
  
  def initialize
    self.title = "Categories"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:UIImage.imageNamed("ico-tbi-car"), tag:3)
    self.navigationItem.rightBarButtonItem = ES.systemBBI(UIBarButtonSystemItemCancel, target:self, action:'close')
  end

  def viewWillAppear(animated)
    super
    tableView.reloadData # refresh badges
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    Category.all.count + 1
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    cell = table.dequeueReusableCell(klass: DSBadgeViewCell)

    if indexPath.row == 0
      cell.textLabel.text = "All Models"
      cell.badgeText = Disk.currentMods.count
    else
      category = Category.all[indexPath.row - 1]
      cell.textLabel.text = category.name
      cell.badgeText = category.selectedModsCount      
    end
    
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    self.category = indexPath.row == 0 ? nil : Category.all[indexPath.row - 1]
    close
  end
  
  ###
  
  def close
    dismissModalViewControllerAnimated(YES, completion:NIL)
  end
end
