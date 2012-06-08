class AppDelegate
  attr_accessor :window, :navigationController
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    self.navigationController = UINavigationController.alloc.initWithRootViewController(ParamsChartController.alloc.init)
    navigationController.delegate = self

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    window.backgroundColor = UIColor.whiteColor
    window.rootViewController = navigationController
    window.makeKeyAndVisible
    
    return true
  end
end

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
  attr_accessor :models, :params, :data

  def viewDidLoad
    super
    
    dataPath = NSBundle.mainBundle.pathForResource("final-models.bin", ofType:"plist")
    self.data = NSMutableArray.alloc.initWithContentsOfFile(dataPath)    
    
    self.params = ['max_power']
    self.models = [
      "ford--focus--2011--hatch_5d---2.0i-150ps-AMT-FWD", 
      "opel--astra--2010--hatch_5d---1.4i-140ps-AT-FWD",
      "volkswagen--golf--2009--hatch_5d---1.4i-122ps-AMT-FWD",
      "honda--civic--2012--sedan---1.8i-142ps-AT-FWD"
    ]
  end

  def tableView(tv, numberOfRowsInSection:section)
    return models.count
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)
    unless cell = tv.dequeueReusableCellWithIdentifier("barCell")
      # cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"cell")
      cell = BarTableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"barCell")
      # cell.selectionStyle = UITableViewCellSelectionStyleNone
      # cell.textLabel.adjustsFontSizeToFitWidth = true
    end
    
    # model_key = models[ip.row]
    # model = data.detect { |hash| hash['key'] == model_key }
    # cell.textLabel.text = "#{model['key']} #{model[params.first]}"
    return cell
  end
  
end


class BarTableViewCell < UITableViewCell
  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
  	if super(UITableViewCellStyleDefault, reuseIdentifier:reuseIdentifier)
      barFrame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height)
      barView = BarView.alloc.initWithFrame(barFrame)
      barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      contentView.addSubview(barView)
    end
  	return self
  end
end

class BarView < UIView
  def initWithFrame(frame)
  	if super(frame)
  		self.opaque = true
  		self.backgroundColor = UIColor.whiteColor
    end
  	return self
  end
  
  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    CGContextSetLineWidth(context, 2.0)
    CGContextSetStrokeColorWithColor(context, UIColor.greenColor.CGColor)
    
    CGContextMoveToPoint(context, 10, 10)
    CGContextAddLineToPoint(context, 200, 20)
    
    CGContextStrokePath(context)
  end  
end
