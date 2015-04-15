class BannerViewController < UIViewController
  attr_accessor :contentController, :bannerView
  
  def initWithContentViewController(contentController)
    init
    self.contentController = contentController
    self.bannerView = ADBannerView.alloc.initWithAdType(ADAdTypeBanner)
    self.bannerView.delegate = self
    self
  end

  def loadView
    contentView = UIView.alloc.initWithFrame UIScreen.mainScreen.bounds
    contentView.addSubview bannerView
  
    addChildViewController contentController
    contentView.addSubview contentController.view
    contentController.didMoveToParentViewController self
  
    self.view = contentView
  end
  
  def preferredInterfaceOrientationForPresentation
    contentController.preferredInterfaceOrientationForPresentation
  end

  def supportedInterfaceOrientations
    contentController.supportedInterfaceOrientations
  end
  
  def preferredStatusBarStyle
    contentController.preferredStatusBarStyle
  end
  
  def viewDidLayoutSubviews
    contentFrame = view.bounds
    bannerFrame = CGRectZero
    bannerFrame.size = bannerView.sizeThatFits contentFrame.size
  
    if bannerView.bannerLoaded?
      contentFrame.size.height -= bannerFrame.size.height
      bannerFrame.origin.y = contentFrame.size.height
    else
      bannerFrame.origin.y = contentFrame.size.height
    end

    contentController.view.frame = contentFrame
    bannerView.frame = bannerFrame
  end
  
  def bannerViewDidLoadAd(banner)
    UIView.animateWithDuration 0.25, animations: lambda {
      view.setNeedsLayout
      view.layoutIfNeeded
    }
  end

  def bannerView(banner, didFailToReceiveAdWithError:error)
    UIView.animateWithDuration 0.25, animations: lambda {
      view.setNeedsLayout
      view.layoutIfNeeded
    }
  end

  # def bannerViewActionShouldBegin(banner, willLeaveApplication:willLeave)
  #   YES
  # end
  #
  # def bannerViewActionDidFinish(banner)
  # end
end
