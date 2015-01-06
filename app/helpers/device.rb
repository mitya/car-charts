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
end

KK.extend(KK::Device)