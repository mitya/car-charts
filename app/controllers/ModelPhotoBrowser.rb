class ModelPhotosController < UIViewController
  attr_accessor :model, :year
  attr_accessor :webView
  
  def initialize(model = nil, year = nil)
    self.model = model
    self.year = year
    self.hidesBottomBarWhenPushed = YES
  end
  
  def viewDidLoad
    self.title = "Photos"
    self.webView = UIWebView.alloc.initWithFrame(view.bounds).tap do |webView|
      webView.backgroundColor = UIColor.scrollViewTexturedBackgroundColor
      webView.delegate = self
      webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      view.addSubview(webView)
    end
  end
  
  def viewWillAppear(animated)
    super
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
  
  # - (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  #   if (navigationType == UIWebViewNavigationTypeLinkClicked) {
  #     [[UIApplication sharedApplication] openURL:request.URL];
  #     return NO;
  #   }
  #   return YES;
  # }
  
end
