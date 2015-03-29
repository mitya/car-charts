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
  def step_1__parse_homepage
    doc = CW.parse_file("crawler_data/p-marks/index.html")
    results = {}

    popular_models_block = doc.css(".l-page__left .b-list_type_alphabet").first
    all_models_block = doc.css(".l-page__left .b-list_type_alphabet").last

    results[:popular] = popular_models_block.css("a").map { |a| [ a['href'][1..a['href'].length], a['href'], a.text ] }
    results[:all] = all_models_block.css("a").map { |a| [ a['href'][1..a['href'].length], a['href'], a.text ] }
    results[:unpopular] = results[:all] - results[:popular]

    CW.write_data "01-marks", results
  end

  def step_2_0__load_marks
    collection = :combined
    links = CW.read_hash('01-marks')[collection]
    links.each { |key, url, title| CW.save_ya_page_and_sleep url, "02-marks/#{collection}/#{key}.html" }
  end

  def step_2_1__load_multipage_marks
    marks = %w(audi bmw chevrolet citroen ford honda hyundai kia mazda mercedes mitsubishi nissan opel peugeot renault toyota vaz volkswagen)
    pages_counts = {mercedes: 3, toyota: 5, nissan: 3}
    pages_counts.default = 2
    marks.each do |mark|
      page_count = pages_counts[mark.to_sym]
      for page in 2..page_count
        CW.save_ya_page_and_sleep "/search?mark=#{mark}&group_by_model=true&page_num=#{page}", "02.1-marks-popular-extra/#{mark}-#{page}.html"
      end
    end
  end

  def step_3__parse_marks
    brand_keys_to_titles = YAML.load_file("crawler/data-brands.yml")['brands']
    
    results = {}

    CW.parse_dir("02-marks") do |doc, basename, path|      
      doc.css("div.b-cars__page a.b-car").each do |a|        
        full_title = a.at_css(".b-car__title").text
        url = a['href']
        
        result = OpenStruct.new
        result.direct = true if url !~ /^\/search/
        result.url = url
        result.full_title = full_title

        if summary = a.at_css(".b-car__summary")
          result.summary = summary.xpath('text()').text.sub(/, $/, '')
          result.years = a.at_css('.b-car__year-range').text
        end

        if generations = a.at_css(".b-car__count")
          result.generations = generations.text
        end        
      
      
        if url.start_with?('/search')
          # /search?mark=acura&model=tsx&no_redirect=true&group_by_model=false
          result.mark = url.scan(%r{mark=(\w+)}).first.first
          result.model = url.scan(%r{(?:\?|\&)model=(\w+)}).first.first
        else
          # /acura/ilx/20291740
          result.mark, result.model = url.scan(%r{^/(\w+)/(\w+)}).first
        end
        
        result.title = full_title.sub brand_keys_to_titles[result.mark] + ' ', '' # Ford Focus => Focus
                
        result.key = "#{result.mark}--#{result.model}"

        results[result.key] = CW.stringify_keys(result)
      end
    end

    CW.write_data "03-models", results
  end

  def step_4_0__load_generations
    sources = CW.read_hash('03-models').shuffle
    sources.each do |url, data|
      next if data.direct_link
      CW.save_ya_page_and_sleep url, "04-generations/#{ data.mark_key }--#{ data.title }.html", overwrite: false
    end
  end

  def step_4_0__compress_generations
    CW.compress_dir("04-generations", ".b-tabs__panel_name_cars .b-cars__page")
  end


  def step_4
    step_4_1__parse_generations
    step_4_2__load_model_years
    step_4_3__compress_model_years
    step_4_4__rename_models_without_bodies
    step_4_5__extract_other_bodytypes
    step_4_6__load_other_bodytypes
    step_4_7__compress_other_body_types
  end

  def step_4_1__parse_generations
    results = {}

    CW.parse_dir("04.0-generations.min", silent: true) do |doc, basename, path|
      mark_key = basename.sub(/-\d$/, '') # mercedes-7 => mercedes
      doc.css("div.b-cars__page a.b-car").each do |a|
        mark, model = a['href'].scan(%r{^/(\w+)/(\w+)}).first
        key = "#{mark}--#{model}"
        url = a['href']
        result = {}
        result['key'] = key
        result['url'] = url
        result['summary'] = a.css('.b-car__summary').xpath('text()').text.sub(/, $/, '')
        result['years'] = a.at_css('.b-car__year-range').text
        result['full_title'] = a.at_css(".b-car__title").text
        results[url] = result
      end
    end
    
    models = CW.read_hash('03.0-models', openstruct: false).values
    models.select! { |m| m.delete('direct') }
    models.each do |model|
      result = {}
      result['key'] = model['key']
      result['url'] = model['url']
      result['years'] = model['years']
      result['summary'] = model['summary']
      results[model['url']] = result
    end
    
    results.each_value do |res|
      res['years_since'], res['years_till'] = res.delete('years').split(' – ').map(&:to_i)
    end
    
    filtered_results = results.reject { |key, res| res['years_till'] && res['years_till'] < 2013 }
    puts "leave #{filtered_results.count} of #{results.count} results"

    # p filtered_results.values.count
    # p filtered_results.values.uniq { |q| [q['key'], q['years_since']]  }.count
    # generations.uniq! { |q| [q.title, q.years_since] } # there are a few dups (same model, same years, different bodies)
    
    CW.write_data "04.1-generations", filtered_results
  end
  
  def step_4_2__load_model_years
    generations = CW.read_hash('04.1-generations')
    generations.shuffle.each do |gen|
      filename = [gen.mark_key, gen.model_key, gen.years_since].join(' ')
      CW.save_ya_page_and_sleep gen.url + "/specs", "04.2-bodies/#{filename}.html", overwrite: false
    end
  end
  
  def step_4_3__compress_model_years
    CW.compress_dir("04.2-bodies", nil, ".b-complectations, .b-car-head, .b-specifications, .catalog-filter")
  end


  # Renames the model files include the bodytype looked up from the inside of a file
  # Also converts weird bodytypes to standard ones when possible
  # And drops files with unknown bodytypes
  #
  # volkswagen passat 2011                   => /opt/work/carchartscrawler/data_1502/04.2-bodies/volkswagen passat 2011 sedan.html
  # volkswagen passat 2014                   => /opt/work/carchartscrawler/data_1502/04.2-bodies/volkswagen passat 2014 wagon.html
  #
  # The output dir contains the same files just with longer names
  # Also it drops files with weird bodytypes
  #
  def step_4_4__rename_models_without_bodies  
    reductions = YAML.load_file("crawler/data-reductions.yml")
    new_dir = WORKDIR + "04.4-bodies-renamed"
    FileUtils.mkdir_p(new_dir)

    CW.parse_dir("04.2-bodies", silent: true) do |doc, basename, path|    
      selector = doc.css(".b-bodytypes").any? ? 'b-bodytypes' : 'bodytypes'
      body_name = doc.css(".#{selector} .button__text").text
      body_name = doc.css(".#{selector}").text if body_name.empty?

      mark = basename.split.first
      body_key = CW.parse_bodytype(mark, body_name)
      
      next unless body_key

      new_path = new_dir + "#{basename} #{body_key}.html"
      printf "%-20s %30s => %s\n", 'rename', basename, new_path
      FileUtils.cp(path, new_path)
    end
  end

  def step_4_5__extract_other_bodytypes
    other_bodytype_urls = {}

    CW.parse_dir("04.2-bodies") do |doc, basename, path|
      selector = doc.css(".b-bodytypes").any? ? '.b-car-head .b-bodytypes' : '.bodytypes'
      doc.css("#{selector} a.link").each do |a|
        mark_key = basename.split.first
        url = a['href']
        bodytype_name = a.text
        bodytype_key = CW.parse_bodytype(mark_key, bodytype_name)
        next unless bodytype_key

        other_bodytype_urls["#{basename} #{bodytype_key}"] = url
      end
    end     
    
    CW.write_data "04.5-bodies-other", other_bodytype_urls
  end

  def step_4_6__load_other_bodytypes
    dir = "04.6-bodies-other"
    models = CW.read_hash('04.5-bodies-other', openstruct:false)
    models.to_a.shuffle.each do |key, url|
      CW.save_ya_page_and_sleep url, "#{dir}/#{key}.html", overwrite: false, test: false
    end
  end

  def step_4_7__compress_other_body_types
    CW.compress_dir("04.6-bodies-other", nil, ".b-complectations, .b-car-head, .b-specifications, .catalog-filter")
  end

  def step_6
    step_6_1__parse_models
  end

  def step_6_1__parse_models
    results = {}
    other_body_urls = {}
    mods = [] # unique mods that should be parsed as is

    dirs = %w(04.4-bodies-renamed 04.6-bodies-other)
    # files = ['jeep wrangler 2007 suv_3d', 'volkswagen multivan 2009 minivan_long', 'land_rover defender 2007 suv_3d', 'suzuki grand_vitara 2012 suv_3d']

    CW.parse_dir(dirs, only:nil) do |doc, basename, path|
      doc.css(".b-car-head .b-bodytypes a.link").each do |a|
        other_body_urls["#{basename} -- #{a.text}"] = a['href']
      end           
      
      complectations = doc.css(".b-complectations__item:not(.b-complectations__item_state_current) a.link")
      if complectations.any?
        complectations.each do |a|
          aggregate_key = CW.parse_ya_aggregate_title(a['title'])
          key = [ basename.split.join('-'), aggregate_key ].join('--')
          results[key] = a['href']
        end
      else        
        mods << basename
      end
    end

    CW.write_data "06.1-mods", results
    CW.write_data "06.1-mods-singles", mods
    CW.write_data "06.1-bodies-other", other_body_urls
  end

  def step_7
    step_7_0__load_mods
    step_7_1__compress_mods
  end

  def step_7_0__load_mods
    mods = CW.read_hash('06.1-mods', openstruct: false)
    mods.to_a.shuffle.each do |key, url|
      CW.save_ya_page_and_sleep url, "07.0-mods/#{key}.html", overwrite: false, test: false
    end
  end

  def step_7_1__compress_mods
    CW.compress_dir("07.0-mods", nil, ".b-specifications")
  end


  def check_which_marks_have_many_pages
    CW.parse_dir("marks/popular_manual") do |doc, basename, path|
      unless doc.css(".b-tabs__panel_name_cars .b-show-more__button").any?
        puts "REMOVE #{filename}"
        File.delete(filename)
      end
    end
  end
  
  def remove_dups_from_other
    Dir.glob(WORKDIR + "04.6-bodies-other/*.html") do |path|
      basename = File.basename(path)
      path2 = WORKDIR + "04.4-bodies-renamed/#{basename}"
      size1 = File.size(path)
      size2 = File.size(path2) if File.exist?(path2)
      is_dup = File.exist?(path2) && (size1 - size2.to_i).abs < 10
      puts "kill #{path}"
      File.delete(path) if is_dup
    end
  end
end
