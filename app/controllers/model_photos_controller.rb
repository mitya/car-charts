class ModelPhotosController < UIViewController
  attr_accessor :model, :year
  attr_accessor :webView, :spinner, :goForwardBBI, :goBackBBI, :webViewIsLoaded
  
  def initialize(model = nil, year = nil)
    self.model = model
    self.year = year
    navigationItem.rightBarButtonItem = KK.systemBBI(UIBarButtonSystemItemDone, target:self, action:'close')
  end

  
  def viewDidLoad
    self.title = "Photos"

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
      query = model.name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
      path = "http://www.google.com/search?num=10&tbm=isch&q=#{query}"
      url = NSURL.URLWithString(path)
      error = Pointer.new(:object)
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
    
    if webView.canGoBack || webView.canGoForward
      self.toolbarItems ||= [KK.flexibleSpaceBBI, goBackBBI, KK.flexibleSpaceBBI, goForwardBBI, KK.flexibleSpaceBBI]
      navigationController.setToolbarHidden(NO, animated:YES)
    end
  end  
end
