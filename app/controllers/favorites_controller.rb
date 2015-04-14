class FavoritesController < UITableViewController
  attr_accessor :generations
  
  def initialize
    self.title = "Favorites"
    self.generations = Disk.favorites
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Sets", image:KK.image("tab-star"), selectedImage:KK.image("tab-star-full"))
    Disk.addObserver(self, forKeyPath:"currentMods", options:NO, context:nil)
    Disk.addObserver(self, forKeyPath:"favorites", options:NO, context:nil)
  end

  def dealloc
    Disk.removeObserver(self, forKeyPath:"currentMods")
    Disk.removeObserver(self, forKeyPath:"favorites")
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    case keyPath
    when 'currentMods', 'favorites'
      tableView.reloadData
    end
  end


  def viewDidLoad
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end

  def tableView(tableView, numberOfRowsInSection:section)
    generations.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCell(style: UITableViewCellStyleValue1) do |cell|
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      cell.textLabel.adjustsFontSizeToFitWidth = YES      
    end   

    generation = generations[indexPath.row]

    cell.textLabel.attributedText = generation.nameAttributedString
    cell.detailTextLabel.text = generation.selectedModsCount.to_s_or_nil
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
    generation = generations[indexPath.row]
    navigationController.pushViewController ModListController.new(generation), animated:true
  end
end
