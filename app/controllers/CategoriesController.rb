class CategoriesController < UITableViewController
  CustomSection = 0
  CustomSectionRecent = 0
  CustomSectionAll = 1
  CategoriesSection = 1
  
  def initWithStyle(style)
    super
    self.title = "Car Classes"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Cars", image:UIImage.imageNamed("ico-tab-categories.png"), tag:1)
    @category_names = Static.category_names
    self
  end  
  
  def viewWillAppear(animated)
    super
    tableView.reloadData
  end
  
  def numberOfSectionsInTableView(tv)
    2
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    case section
      when CustomSection then 2
      when CategoriesSection then @category_names.count
    end
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    cell = table.dequeueReusableCell(klass: BadgeViewCell)
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    case indexPath.section 
    when CategoriesSection
      category_key = @category_names.keys[indexPath.row]
      category_name = Static.category_names[category_key.to_sym]
      category_models = Model.model_classes[category_key.to_s]
      category_selected_mods_count = Model.current_mods.map(&:category).map(&:to_sym).select{ |c| c == category_key}.count

      cell.textLabel.text = category_name
      cell.badgeText = category_selected_mods_count.to_s if category_selected_mods_count > 0
    when CustomSection
      case indexPath.row 
      when CustomSectionAll
        cell.textLabel.text = "All"
        cell.badgeText = Model.current_mods.count.to_s if Model.current_mods.any?
      when CustomSectionRecent
        cell.textLabel.text = "Recent"
        cell.badgeText = Model.current_mods.count.to_s if Model.current_mods.any?
      end
    end
    
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    case indexPath.section
    when CategoriesSection
      category_key = @category_names.keys[indexPath.row]
      category_models = Model.model_classes[category_key.to_s]
      controller = ModelsController.alloc.initWithStyle(UITableViewStyleGrouped)
      controller.model_keys = category_models
    when CustomSection
      case indexPath.row
      when CustomSectionRecent
        controller = RecentModificationsController.alloc.initWithStyle(UITableViewStyleGrouped)
      when CustomSectionAll
        controller = ModelsController.alloc.initWithStyle(UITableViewStyleGrouped)
        controller.model_keys = Model.all_model_keys
      end
    end

    navigationController.pushViewController(controller, animated:true)
  end
end
