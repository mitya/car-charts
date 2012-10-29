class ModelPhotosController < UIViewController
  attr_accessor :model
  attr_accessor :webView
  
  SafariUA = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"
  
  def initialize(model = nil)
    self.model = model
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

    query = model.name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    path = "http://www.google.com/search?num=10&tbm=isch&q=#{query}"
    url = NSURL.URLWithString(path)
    error = Pointer.new(:object)
    request = NSMutableURLRequest.requestWithURL(url)
    request.setValue(SafariUA, forHTTPHeaderField:"User-Agent")
    response = Pointer.new(:object)
    data = NSURLConnection.sendSynchronousRequest(request, returningResponse:response, error:error)
    html = NSString.alloc.initWithData(data, encoding:NSUTF8StringEncoding)
    html ? webView.loadHTMLString(html, baseURL:url) : puts("HTML Loading Failed: #{error.value.description}")
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
