class YA2HomepageParser
  def parse_homepage
    doc = CW.parse_file("crawler_data/p-vendors/index.html")
    results = {}    
    
    popular_models_block = doc.css(".l-page__left .b-list_type_alphabet").first
    all_models_block     = doc.css(".l-page__left .b-list_type_alphabet").last
    
    results[:popular]     = popular_models_block.css("a").map { |a| [ a['href'][1..a['href'].length], a['href'], a.text ] }
    results[:all]         = all_models_block.css("a").map { |a| [ a['href'][1..a['href'].length], a['href'], a.text ] }
    results[:non_popular] = results[:all] - results[:popular]
    
    CW.write_data "vendors", results
  end
  
  def load_vendors
    collection = 'popular'
    links = CW.read_hash('vendors')[collection]
    links.each { |key, url, title| CW.save_ya_page_and_sleep url, "p-vendors/#{collection}/#{key}.html" }
  end
  
  def parse_vendors
    results = []
    
    Dir.glob(WORKDIR + "p-vendors/popular/*.html").each do |filename|
      vendor_key = File.basename(filename, '.html')
      doc = CW.parse_file(filename)
      
      doc.css("div.b-cars__page a.b-car").each do |a|
        result = OpenStruct.new
        result.vendor_key = vendor_key
        result.url = a['href']
        result.title = a.at_css(".b-car__title").text
        result.direct_link = true if a['href'] !~ /^\/search/

        if summary = a.at_css(".b-car__summary")
          result.summary = summary.text
        end
        
        if generations = a.at_css(".b-car__count")
          result.generations = generations.text
        end
        
        results << result.to_h
      end
    end
  
    CW.write_data "vendor-popular", results
  end
  
  def load_model_families
    sources = CW.read_hash('vendor-popular').shuffle.map { |hash| OpenStruct.new(hash) }
    sources.reject(&:direct_link).each do |source|
      CW.save_ya_page_and_sleep source.url, "p-families/#{ source.vendor_key }--#{ source.title }.html", overwrite: false
    end
  end
  
  def run
    # parse_homepage
    # load_vendors
    # parse_vendors
    load_model_families
  end
end
