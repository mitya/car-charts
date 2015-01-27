# There are few html sets of different marks
#   * popular crawled
#   * popular downloaded manually because those pages have pagination
#   * all crawled
#   * combined is selected unpopular + all popular downloaded manually
# 
# It was possible to load all the direct links to models instead of loading links to generations.
# But it requires dealing with pagination on the mark pages.
# 
class YA2Processor
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
    CW.compress_dir("generations", ".b-tabs__panel_name_cars .b-cars__page")
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
  
  def load_models_2
    models = CW.read_hash('models-other-2')    
    models.shuffle.each do |model|      
      filename = model.body_key
      CW.save_ya_page_and_sleep model.url, "models-other/#{filename}.html", overwrite: false
    end
  end  
  
  def compress_models
    CW.compress_dir("models-other", ".b-complectations, .b-car-head, .b-specifications")
  end
  
  def rename_models_without_bodies
    Dir.glob(WORKDIR + "models-initial/*.html").each do |path|
      basename = File.basename(path, '.html')
      doc = CW.parse_file(path, silent: true)
      
      body_name = doc.css(".b-bodytypes .button__text").text
      body_name = doc.css(".b-bodytypes").text if body_name.empty?
      
      mark = basename.split.first.to_sym
      reduction = CWD::Reductions_Body_Body[ [mark, body_name] ]
      body_name = reduction if reduction

      body_key = CWD::Bodies[body_name]

      new_name = body_key ? basename + ' ' + body_key.to_s : 'x ' + basename
      new_name = File.dirname(path) + '/' + new_name + '.html'
      
      printf "%-40s => %s\n", basename, new_name      
      File.rename(path, new_name)
    end
  end
  
  def parse_models_for_bodies
    results = []
    
    CW.parse_dir("models-initial") do |doc, basename, path|
      doc.css(".b-car-head .b-bodytypes a.link").each do |a|
        results << { key: basename, url: a['href'], title: a.text }
      end
    end
  
    CW.write_data "models-other", results
    
    # extract names of other generations
    # extract links to mods
    # load mods
    
    # load other bodies
    # extract links to mods
    # load mods
    
    # parse mods
  end
  
  def parse_models_for_mods
    results = []
    
    CW.parse_dir("models-all") do |doc, basename, path|
      complectations = doc.css(".b-complectations__item:not(.b-complectations__item_state_current) a.link")
      if complectations.any?
        complectations.each do |a|
          aggregate_key = parse_ya_aggregate_title(a['title'])
          key = [ basename.split.join('-'), aggregate_key ].join('--')
          results << OpenStruct.new( key: key, url: a['href'] )
        end
      else
        # unique models
      end      
    end    
    
    results.uniq! { |r| r.key }
    
    CW.write_data "mods", results
  end
  
  def process_mods
    records = CW.read_hash('mods')
    
    urls = records.map &:url
    p urls.count
    p urls.uniq.count    
  end
  
  def process_models_2
    records = CW.read_hash('models-other')    
    default_bodies = Set.new CWD::Bodies.keys
    
    records.each do |r|
      mark = r.key.split.first.to_sym
      if reduction = CWD::Reductions_Body_Body[ [mark, r.title] ]
        r.title = reduction
      end
    end
    
    records.select! { |r| default_bodies.include? r.title }
    
    records.each { |r| r.body_key = "#{ r.key } #{ CWD::Bodies[r.title] }" }
    
    CW.write_data "models-other-2", records
  end
  
  def load_mods
    mods = CW.read_hash('mods')
    mods.shuffle.each do |mod|
      CW.save_ya_page_and_sleep mod.url, "mods/#{mod.key}.html", overwrite: false
    end    
  end
  
  def work
    results = []
    records = CW.read_hash('models-other')
    
    default_bodies = Set.new CWD::Bodies.keys    
    excluded_bodies = %w(микроавтобус фургон)
    
    records.each do |r|
      mark = r.key.split.first.to_sym
      if reduction = CWD::Reductions_Body_Body[ [mark, r.title] ] 
        r.title = reduction
      end
    end
    
    records.reject! { |r| r.title.start_with?(*excluded_bodies) }
    records.reject! { |r| default_bodies.include? r.title }
    
    records.sort_by!(&:key)
    
    records.each do |r|
      printf "%-45s %s\n", r.url, r.title
      results << [r.key, YA_HOST + r.url, r.title]
    end
    
    CW.write_csv(results)
  
  end
  
  private
  
  # Momentum 1.6 AMT (150 л.с.) передний привод, бензин
  # sDrive30i 3.0 AT (258 л.с.) задний привод, бензин  
  # 1.4 MT (125 л.с.) передний привод, бензин
  def parse_ya_aggregate_title(title)
    re = /(\d\.\d) (\w{2,3}) \((\d+) л\.с\.\) (\p{L}+) привод, ([\p{L}\s\/]+)$/
    volume, transmission, power, drive, fuel = title.scan(re).flatten
    transmission_key = transmission
    drive_key = CWD::Translations_Values[:drive][drive]
    fuel_key = CWD::Translations_Values[:fuel_short][fuel]
    "#{volume}#{fuel_key}-#{power}ps-#{transmission_key}-#{drive_key}"
  end
end
