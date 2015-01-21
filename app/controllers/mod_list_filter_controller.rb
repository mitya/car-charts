class ModListFilterController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  
  attr_accessor :filter, :popover

  def initialize
    self.title = "Filter Settings"
    self.filter = Disk.filterOptions.dup
    self.navigationItem.rightBarButtonItem = KK.systemBBI(UIBarButtonSystemItemDone, target:self, action:'close')
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end  


  def numberOfSectionsInTableView(tv)
    3
  end
    
  def tableView(tv, numberOfRowsInSection:section)
    {0 => 2, 1 => 2, 2 => 3}[section]
  end


  def tableView(tv, titleForHeaderInSection:section)
    {0 => "Transmission", 1 => "Fuel", 2 => "Body Type"}[section]
  end


  def tableView(table, cellForRowAtIndexPath:indexPath)
    cell = table.dequeueReusableCell selectionStyle:UITableViewCellSelectionStyleNone do |cell|
      switch = UISwitch.alloc.initWithFrame(CGRectZero)
      switch.addTarget self, action:'switchUpdated:', forControlEvents:UIControlEventTouchUpInside
      cell.accessoryView = switch
    end

    options = self.class.tableOptions[ [indexPath.section, indexPath.row] ]
    
    cell.textLabel.text = options[:title]
    cell.accessoryView.on = filter[ options[:key] ] != false
    return cell
  end
  
  def switchUpdated(switch)
    cell = KK.closestSuperviewOfType(UITableViewCell, forView:switch)
    indexPath = tableView.indexPathForCell(cell)
    options = self.class.tableOptions[ [indexPath.section, indexPath.row] ]
    filter[ options[:key] ] = switch.isOn
    Disk.filterOptions = filter if popover
  end


  def close
    Disk.filterOptions = filter
    if KK.iphone?
      dismissModalViewControllerAnimated true, completion:nil
    else
      popover.dismissPopoverAnimated true if popover
    end
  end
  
  
  def self.tableOptions
    @tableOptions ||= {
      [0, 0] => { key: :mt,     title: "Manual" },
      [0, 1] => { key: :at,     title: "Automatic" },
      [1, 0] => { key: :gas,    title: "Gas" },
      [1, 1] => { key: :diesel, title: "Diesel" },
      [2, 0] => { key: :sedan,  title: "Sedan" },
      [2, 1] => { key: :hatch,  title: "Hatchback" },
      [2, 2] => { key: :wagon,  title: "Wagon" }
    }
  end
end
