class CategoriesController < UITableViewController
  def viewDidLoad
    super
    @data = StaticData[:category_names]
    @keys = @data.keys
    self.title = "Select Car Class"
  end  
  
  def tableView(tv, numberOfRowsInSection:section)
    @data.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    key = @data.keys[indexPath.row]
    category = @data[key]

    unless cell = table.dequeueReusableCellWithIdentifier("cell")
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "cell")
    end

    cell.textLabel.text = StaticData[:category_names][key.to_sym]
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell
  end

  # def tableView(table, didSelectRowAtIndexPath:indexPath)
  #   tableView.deselectRowAtIndexPath(indexPath, animated: true)
  #   cell = tableView.cellForRowAtIndexPath(indexPath)
  #   parameter = Model.parameters[indexPath.row]
  #   
  #   if cell.accessoryType == UITableViewCellAccessoryCheckmark
  #     cell.accessoryType = UITableViewCellAccessoryNone
  #     Model.current_parameters = Model.current_parameters - [parameter.key.to_s]
  #   else
  #     cell.accessoryType = UITableViewCellAccessoryCheckmark
  #     Model.current_parameters = Model.current_parameters + [parameter.key.to_s]
  #   end
  # end
end
