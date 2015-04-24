class ModelPhotosController < UIViewController
  attr_accessor :model, :bodytype
  attr_accessor :query
  attr_accessor :webView, :spinner, :goForwardBBI, :goBackBBI, :webViewIsLoaded

  def initialize(model = nil, bodytype = nil)
    self.model = model
    self.bodytype = bodytype
    navigationItem.rightBarButtonItem = KK.systemBBI(UIBarButtonSystemItemDone, target:self, action:'close') if KK.ipad?
  end

  def viewDidLoad
    self.query = "#{model.name} #{bodytype}"
    self.title = query

    self.webView = UIWebView.alloc.initWithFrame(view.bounds).tap do |webView|
      webView.backgroundColor = UIColor.scrollViewTexturedBackgroundColor
      webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      view.addSubview(webView)
    end
    
    self.spinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray).tap do |spinner|
      spinner.center = [webView.center.x, webView.center.y - spinner.bounds.height * 2]
      view.addSubview(spinner)
    end
    
    self.goBackBBI = KK.imageBBI("bi-navBack", target:webView, action:'goBack')
    self.goForwardBBI = KK.imageBBI("bi-navForward", target:webView, action:'goForward')
  end
  
  def viewWillAppear(animated)
    super
    webView.delegate = self
    webViewIsLoaded || begin
      queryString = query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
      path = "http://www.google.com/search?num=10&tbm=isch&q=#{queryString}"
      url = NSURL.URLWithString(path)
      request = NSMutableURLRequest.requestWithURL(url)
      request.setValue(UISafariUA, forHTTPHeaderField:"User-Agent")
      spinner.startAnimating
      webView.loadRequest(request)
    end    
  end

  def viewWillDisappear(animated)
    super    
    webView.delegate = nil
    webView.stopLoading
    spinner.stopAnimating
  end
  
  def close
    dismissSelfAnimated
  end

  def webViewDidFinishLoad(webView)
    self.webViewIsLoaded = true
    spinner.stopAnimating
    goBackBBI.enabled = webView.canGoBack
    goForwardBBI.enabled = webView.canGoForward
    
    offset = KK.iphone?? 85 : 100
    webView.scrollView.setContentOffset CGPointMake(0, offset), animated:YES if webView.scrollView.contentOffset.y == 0 || webView.scrollView.contentOffset.y == -64
    
    if webView.canGoBack || webView.canGoForward
      self.toolbarItems ||= [KK.flexibleSpaceBBI, goBackBBI, KK.flexibleSpaceBBI, goForwardBBI, KK.flexibleSpaceBBI]
      navigationController.setToolbarHidden(NO, animated:YES)
    end
  end  

  def screenKey
    { model: model.key, bodytype: bodytype }
  end
end
