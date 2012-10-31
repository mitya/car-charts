class ModelPhotosController < UIViewController
  attr_accessor :model, :year
  attr_accessor :webView, :goForwardBBI, :goBackBBI, :webViewIsLoaded
  
  def initialize(model = nil, year = nil)
    self.model = model
    self.year = year
    self.hidesBottomBarWhenPushed = iphone?
  end
  
  def viewDidLoad
    self.title = "Photos"

    self.webView = UIWebView.alloc.initWithFrame(view.bounds).tap do |webView|
      webView.backgroundColor = UIColor.scrollViewTexturedBackgroundColor
      webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      view.addSubview(webView)
    end
    
    navigationItem.rightBarButtonItem = ES.systemBBI(UIBarButtonSystemItemDone, target:self, action:'close')
    navigationItem.hidesBackButton = YES
    
    self.goBackBBI = ES.imageBBI("bbi-left", style:UIBarButtonItemStylePlain, target:webView, action:'goBack')
    self.goForwardBBI = ES.imageBBI("bbi-right", style:UIBarButtonItemStylePlain, target:webView, action:'goForward')    
  end
  
  def viewWillAppear(animated)
    super
    webView.delegate = self
    return if webViewIsLoaded
    
    query = "#{model.name} #{year}".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    path = "http://www.google.com/search?num=10&tbm=isch&q=#{query}"
    url = NSURL.URLWithString(path)
    error = Pointer.new(:object)
    request = NSMutableURLRequest.requestWithURL(url)
    request.setValue(SafariUA, forHTTPHeaderField:"User-Agent")
    webView.loadRequest(request)
  end

  def viewWillDisappear(animated)
    super    
    webView.delegate = nil
    webView.stopLoading
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  ####

  def close
    navigationController.popViewControllerAnimated(YES)
  end

  def webViewDidFinishLoad(webView)
    self.webViewIsLoaded = true
    goBackBBI.enabled = webView.canGoBack
    goForwardBBI.enabled = webView.canGoForward
    if webView.canGoBack || webView.canGoForward
      self.toolbarItems ||= [ES.flexibleSpaceBBI, goBackBBI, ES.flexibleSpaceBBI, goForwardBBI, ES.flexibleSpaceBBI]
      navigationController.setToolbarHidden(NO, animated:YES)
    end
  end  
end
