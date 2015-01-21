# Represents a category of models, e.g. 'E class'.
class ModelCategoriesController < UITableViewController
  attr_accessor :category
  
  def initialize
    self.title = "Categories"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("ti-car"), tag:3)
    self.navigationItem.rightBarButtonItem = KK.systemBBI(UIBarButtonSystemItemCancel, target:self, action:'close')
  end

  def viewWillAppear(animated)
    super
    tableView.reloadData # refresh badges
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end  

  
  
  def tableView(tv, numberOfRowsInSection:section)
    Category.all.count + 1
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    cell = table.dequeueReusableCell(style: UITableViewCellStyleValue1)

    if indexPath.row == 0
      cell.textLabel.text = "All Models"
      cell.detailTextLabel.text = Disk.currentMods.count.to_s_or_nil
    else
      category = Category.all[indexPath.row - 1]
      cell.textLabel.text = category.name
      cell.detailTextLabel.text = category.selectedModsCount.to_s_or_nil
    end
    
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    self.category = indexPath.row == 0 ? nil : Category.all[indexPath.row - 1]
    close
  end
  

  
  def close
    dismissSelfAnimated
  end
end
