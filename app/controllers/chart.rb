class ChartController < UITableViewController
  attr_accessor :mods, :params, :comparision, :data

  def viewDidLoad
    super
    # @mods = Model.metadata['classes']['C'].map do |model_key|
    #     Model.modifications_by_model_key[model_key]
    #   end.flatten.select(&:automatic?).select(&:hatch?)    

    @mods = Model.current_models.map { |model_key| Model.modifications_by_model_key[model_key] }.flatten.select(&:automatic?)
    @comparision = Comparision.new(mods, Model.current_parameters.dup)

    self.tableView.rowHeight = 25
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone # UITableViewCellSeparatorStyleSingleLine

    self.navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Chart", style:UIBarButtonItemStyleBordered, target:nil, action:nil)
    self.navigationController.toolbarHidden = false
    # self.navigationItem.rightBarButtonItem = @paramsButton

    self.toolbarItems = [
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithTitle("Models", style: UIBarButtonItemStyleBordered, target: self, action: 'showCategories'),
      UIBarButtonItem.alloc.initWithTitle("Params", style: UIBarButtonItemStyleBordered, target: self, action: 'showParameters'),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
    ]
  end
  
  def viewWillAppear(animated)
    super    
    # if comparision.params != Model.current_parameters
    @comparision = Comparision.new(mods, Model.current_parameters.dup)
    tableView.reloadData 
    self.title = comparision.title
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def tableView tv, numberOfRowsInSection:section
    mods.count
  end
  
  def tableView tv, cellForRowAtIndexPath:ip
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
    height += 2 if item.last?
    height += (comparision.params.count - 1) * BarFullHeight
    height += 4
    height
  end
  
  def showParameters
    controller = ParametersController.alloc.initWithStyle(UITableViewStyleGrouped)
    navigationController.pushViewController(controller, animated:true)
  end  

  def showCategories
    controller = CategoriesController.alloc.initWithStyle(UITableViewStyleGrouped)
    navigationController.pushViewController(controller, animated:true)
  end  
end
