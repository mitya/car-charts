module KK::Common
  def app
    UIApplication.sharedApplication
  end
  
  def defaults
    NSUserDefaults.standardUserDefaults
  end

  def indexPath(section, row)
    NSIndexPath.indexPathForRow(row, inSection: section)
  end

  def sequentialIndexPaths(section, firstRow, lastRow)
    return [] if firstRow > lastRow
    firstRow.upto(lastRow).map { |row| indexPath(section, row) }
  end

  def ptr(type = :object)
    Pointer.new(type)
  end

  def documentsURL    
    NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).first   
  end    
  
  def documentsPath
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).first
  end
  
  def bundlePath
    NSBundle.mainBundle.resourcePath
  end
  
  def env?(variable)
    NSBundle.mainBundle.objectForInfoDictionaryKey(variable) == true
  end
  
  def navigationForController(controller, withDelegate:delegate)
    UINavigationController.alloc.initWithRootViewController(controller).tap do |navigation|
      navigation.delegate = delegate
    end
  end
  
  def closestSuperviewOfType(type, forView:view)
    view = view.superview until view.is_a?(type) || view.nil?
    return view
  end
  
  def debug(message, *args)
    NSLog(message, *args) if DEBUG
  end
  
  def assert_present(value)
    raise "Non-null value is #{value.inspect}" if value == nil || value == 0 || value.is_a?(String) && value.empty?
    value
  end
end

KK.extend(KK::Common)
