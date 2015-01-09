module KK::Device
  def landscape?(orientation = UIApplication.sharedApplication.statusBarOrientation)
     orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight
  end

  def portrait?(orientation = UIApplication.sharedApplication.statusBarOrientation)
     orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown
  end

  def orientationKey(orientation = UIApplication.sharedApplication.statusBarOrientation) 
    portrait?(orientation) ? :portrait : :landscape
  end
  
  def currentScreenHeight
    portrait?? UIScreen.mainScreen.bounds.height : UIScreen.mainScreen.bounds.width
  end

  def ipad?
    return $device_is_ipad if $device_is_ipad != nil
    $device_is_ipad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
  end

  def iphone?
    return $device_is_iphone if $device_is_iphone != nil
    $device_is_iphone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone
  end
  
  def image(filename)
    UIImage.imageNamed("images/#{filename}.png") or fail "Image '#{filename}' was not found."
  end
  
  def templateImage(filename)
    image(filename).imageWithRenderingMode(UIImageRenderingModeAlwaysTemplate)
  end
end

KK.extend(KK::Device)
