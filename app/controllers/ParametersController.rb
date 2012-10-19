class ParametersController < UITableViewController
  def initialize
    self.title = "Select Parameters"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Parameters", image:UIImage.imageNamed("ico-tbi-weight"), tag:1)
  end

  def viewDidLoad
    # navigationItem.rightBarButtonItem = ES.systemBBI(UIBarButtonSystemItemDone, target:self, action:'closeSelf')
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    Parameter.all.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    parameter = Parameter.all[indexPath.row]

    cell = table.dequeueReusableCell { |cell| cell.selectionStyle = UITableViewCellSelectionStyleNone }
    cell.textLabel.text = parameter.name  
    cell.accessoryType = Disk.currentParameters.include?(parameter) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory

    parameter = Parameter.all[indexPath.row]
    Disk.currentParameters = Disk.currentParameters.dupWithToggledObject(parameter)
  end
  
  # def closeSelf
  #   dismissModalViewControllerAnimated true
  # end
end
