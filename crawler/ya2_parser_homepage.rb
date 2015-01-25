# There are few html sets of different marks
#   * popular crawled
#   * popular downloaded manually because those pages have pagination
#   * all crawled
#   * combined is selected unpopular + all popular downloaded manually
# 
# It was possible to load all the direct links to models instead of loading links to generations.
# But it requires dealing with pagination on the mark pages.
# 
class YA2HomepageParser
  def parse_homepage
    doc = CW.parse_file("crawler_data/p-marks/index.html")
    results = {}    
    
    popular_models_block = doc.css(".l-page__left .b-list_type_alphabet").first
    all_models_block     = doc.css(".l-page__left .b-list_type_alphabet").last
    
    results[:popular]     = popular_models_block.css("a").map { |a| [ a['href'][1..a['href'].length], a['href'], a.text ] }
    results[:all]         = all_models_block.css("a").map { |a| [ a['href'][1..a['href'].length], a['href'], a.text ] }
    results[:unpopular] = results[:all] - results[:popular]
    
    CW.write_data "marks", results
  end
  
  def load_marks
    collection = :combined
    links = CW.read_hash('marks')[collection]
    links.each { |key, url, title| CW.save_ya_page_and_sleep url, "marks/#{collection}/#{key}.html" }
  end
  
  def load_multipage_marks
    marks = %w(audi bmw chevrolet citroen ford honda hyundai kia mazda mercedes mitsubishi nissan opel peugeot renault toyota vaz volkswagen)
    pages_counts = {mercedes: 3, toyota: 5, nissan: 3}
    pages_counts.default = 2
    marks.each do |mark|
      page_count = pages_counts[mark.to_sym]
      for page in 2..page_count
        CW.save_ya_page_and_sleep "/search?mark=#{mark}&group_by_model=true&page_num=#{page}", "marks/popular_extra/#{mark}-#{page}.html"
      end
    end
  end
    
  def compress_marks
    # dir = "marks/combined"
    # dir = "generations"
    CW.parse_dir(dir) do |doc, basename, path|
      content = doc.css('.b-tabs__panel_name_cars .b-cars__page')
      content.xpath('//@data-bem').remove
      
      doc.at_css('body').inner_html = content
      doc.at_css('head').inner_html = ''
      
      CW.write_file(path, doc.to_html)
    end
  end  
    
  def parse_marks
    results = []
    
    CW.parse_dir("marks") do |doc, basename, path|
      mark_key = basename.sub(/-\d$/, '') # mercedes-7 => mercedes
      doc.css("div.b-cars__page a.b-car").each do |a|
        result = OpenStruct.new
        result.mark_key = mark_key
        result.url = a['href']
        result.title = a.at_css(".b-car__title").text
        result.direct_link = true if a['href'] !~ /^\/search/        

        if summary = a.at_css(".b-car__summary")
          result.summary = summary.xpath('text()').text.sub(/, $/, '')
          result.years = a.at_css('.b-car__year-range').text
        end

        if generations = a.at_css(".b-car__count")
          result.generations = generations.text
        end
        
        results << result.to_h
      end
    end
  
    CW.write_data "marks-generations", results
  end
  
  def parse_generations
    results = []
    
    CW.parse_dir("generations") do |doc, basename, path|
      mark_key = basename.sub(/-\d$/, '') # mercedes-7 => mercedes
      doc.css("div.b-cars__page a.b-car").each do |a|
        result = OpenStruct.new
        result.mark_key = mark_key
        result.url = a['href']
        result.title = a.at_css(".b-car__title").text
        result.summary = a.css('.b-car__summary').xpath('text()').text.sub(/, $/, '')
        result.years = a.at_css('.b-car__year-range').text
        results << result.to_h
      end
    end
  
    CW.write_data "generations", results
  end  
  
  def load_generations
    sources = CW.read_hash('marks-generations').shuffle
    sources.reject(&:direct_link).each do |source|
      CW.save_ya_page_and_sleep source.url, "generations/#{ source.mark_key }--#{ source.title }.html", overwrite: false
    end
  end
  
  def check_which_marks_have_many_pages
    CW.parse_dir("marks/popular_manual") do |doc, basename, path|
      unless doc.css(".b-tabs__panel_name_cars .b-show-more__button").any?
        puts "REMOVE #{filename}"
        File.delete(filename)
      end
    end
  end
  
  def process_generations_2
    marks = CW.read_hash('marks-generations').select(&:direct_link)
    generations = CW.read_hash('generations')
    
    marks.each do |mark|
      mark.delete_field(:direct_link)
      generations << mark
    end
    
    CW.write_data "generations-2", generations
  end
  
  def process_generations_3
    generations = CW.read_hash('generations-2')
    generations.each { |info| info.years_since, info.years_till = info.delete_field(:years).split(' – ').map(&:to_i) }
    CW.write_data "generations-3", generations
  end
  
  def process_generations_4
    generations = CW.read_hash('generations-3')
    
    generations.reject! { |q| q.years_till && q.years_till < 2013 }
    generations.sort_by! { |q| q.url }
    generations.uniq! { |q| [q.title, q.years_since] } # there are a few dups (same model, same years, different bodies)
    generations.each do |q|
      q.delete_field(:mark_key)
      q.delete_field(:summary)
      q.mark_key, q.model_key = q.url.scan(%r{^/(\w+)/(\w+)}).first
    end
    
    CW.write_data "generations-4", generations
  end
  
  def load_models
    generations = CW.read_hash('generations-4')    
    generations.shuffle.each do |gen|      
      filename = [gen.mark_key, gen.model_key, gen.years_since].join(' ')
      CW.save_ya_page_and_sleep gen.url + "/specs", "models/#{filename}.html", overwrite: false
    end
  end
end
