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

class ParamsChartController < UITableViewController
  attr_accessor :models, :params, :comparision, :data

  def viewDidLoad
    super
    
    ModelManager.load
    
    self.params = ['max_power']
    self.models = Model.metadata['classes']['C'].map do |model_key|
        Model.modifications_by_model_key[model_key]
      end.flatten.select(&:automatic?).select(&:hatch?)
    
    self.comparision = Comparision.new(models, params)
    
    self.tableView.rowHeight = 25
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone
    # self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine
    # self.tableView.separatorColor = UIColor.lightGrayColor
  end

  def tableView(tv, numberOfRowsInSection:section)
    return models.count
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)
    unless cell = tv.dequeueReusableCellWithIdentifier("barCell")
      # cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"cell")
      cell = BarTableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"barCell")
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      # cell.textLabel.adjustsFontSizeToFitWidth = true
    end
    
    cell.mod = models[ip.row]
    cell.comparision = comparision
    return cell
  end  
end
