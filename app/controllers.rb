class MainViewController < UITableViewController
  attr_accessor :data
  
  def viewDidLoad
    super
    self.title = "Главное окно"
    
    dataPath = NSBundle.mainBundle.pathForResource("final-models.bin", ofType:"plist")
    self.data = NSMutableArray.alloc.initWithContentsOfFile(dataPath)
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    return data.count
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)  
    unless cell = tv.dequeueReusableCellWithIdentifier("cell")
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"cell")
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell.textLabel.adjustsFontSizeToFitWidth = true
    end
    
    item = data[ip.row]
    cell.textLabel.text = item['key']
    return cell
  end
end

class ParamsListController < UITableViewController
  def viewDidLoad
    super
    self.title = "Select Parameters"
  end  
  
  def tableView(tv, numberOfRowsInSection:section)
    Model.parameters.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    parameter = Model.parameters[indexPath.row]

    unless cell = table.dequeueReusableCellWithIdentifier("cell")
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "cell")
      cell.selectionStyle = UITableViewCellSelectionStyleNone
    end

    cell.textLabel.text = parameter.name
    cell.accessoryType = Model.current_parameters.include?(parameter.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    cell = tableView.cellForRowAtIndexPath(indexPath)
    parameter = Model.parameters[indexPath.row]
    
    if cell.accessoryType == UITableViewCellAccessoryCheckmark
      cell.accessoryType = UITableViewCellAccessoryNone
      Model.current_parameters = Model.current_parameters - [parameter.key]
    else
      cell.accessoryType = UITableViewCellAccessoryCheckmark
      Model.current_parameters = Model.current_parameters + [parameter.key]
    end
  end
end

class ParamsChartController < UITableViewController
  attr_accessor :mods, :params, :comparision, :data

  def viewDidLoad
    super
    @mods = Model.metadata['classes']['C'].map do |model_key|
        Model.modifications_by_model_key[model_key]
      end.flatten.select(&:automatic?).select(&:hatch?)    
    @comparision = Comparision.new(mods, Model.current_parameters.dup)
    @paramsButton = UIBarButtonItem.alloc.initWithTitle("Params", style: UIBarButtonItemStyleBordered, target: self, action: 'showParamsScreen')

    self.title = "Power"
    
    self.tableView.rowHeight = 25
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone # UITableViewCellSeparatorStyleSingleLine

    self.navigationController.toolbarHidden = false
    self.navigationItem.rightBarButtonItem = @paramsButton
  end
  
  def viewWillAppear(animated)
    super
    if comparision.params != Model.current_parameters
      @comparision = Comparision.new(mods, Model.current_parameters.dup)
      tableView.reloadData
    end
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def tableView(tv, numberOfRowsInSection:section)
    mods.count
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)
    unless cell = tv.dequeueReusableCellWithIdentifier("barCell")
      cell = BarTableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"barCell")
      cell.selectionStyle = UITableViewCellSelectionStyleNone
    end

    cell.item = comparision.items[ip.row]
    cell
  end
  
  def tableView(tv, heightForRowAtIndexPath:ip)
    item = comparision.items[ip.row]
    height = BarDetailHeight
    height += BarTitleHeight if item.first?
    height += 4 if item.last?
    height += (comparision.params.count - 1) * BarFullHeight
    height
  end
  
  def showParamsScreen
    paramsController = ParamsListController.alloc.initWithStyle(UITableViewStyleGrouped)
    navigationController.pushViewController(paramsController, animated: true)
  end  
end
