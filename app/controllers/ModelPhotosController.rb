class ModelPhotosController < UIViewController
  attr_accessor :model, :year
  attr_accessor :webView, :spinner, :goForwardBBI, :goBackBBI, :webViewIsLoaded
  
  def initialize(model = nil, year = nil)
    self.model = model
    self.year = year
    self.hidesBottomBarWhenPushed = iphone?
    navigationItem.hidesBackButton = YES
    navigationItem.rightBarButtonItem = ES.systemBBI(UIBarButtonSystemItemDone, target:self, action:'close')
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
    
    self.goBackBBI = ES.imageBBI("bbi-left", style:UIBarButtonItemStylePlain, target:webView, action:'goBack')
    self.goForwardBBI = ES.imageBBI("bbi-right", style:UIBarButtonItemStylePlain, target:webView, action:'goForward')
  end
  
  def viewWillAppear(animated)
    super
    webView.delegate = self
    webViewIsLoaded || begin
      query = "#{model.name} #{year}".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
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
    presentingViewController ? dismissModalViewControllerAnimated(YES, completion:NIL) : navigationController.popViewControllerAnimated(YES)
  end

  def webViewDidFinishLoad(webView)
    self.webViewIsLoaded = true
    spinner.stopAnimating
    goBackBBI.enabled = webView.canGoBack
    goForwardBBI.enabled = webView.canGoForward
    if webView.canGoBack || webView.canGoForward
      self.toolbarItems ||= [ES.flexibleSpaceBBI, goBackBBI, ES.flexibleSpaceBBI, goForwardBBI, ES.flexibleSpaceBBI]
      navigationController.setToolbarHidden(NO, animated:YES)
    end
  end  
end
