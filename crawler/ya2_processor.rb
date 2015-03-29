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


  def step_4_1__parse_generations
    # data = CW.read_hash "04.2-generations", openstruct:false
    # p data.count
    # p data.map { |d| d['url'] }.uniq.count
    # p data.map { |d| d['key'] }.uniq.count
    # return
        
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
    CW.compress_dir("04.2-bodies", nil, ".b-complectations, .b-car-head, .b-specifications")
  end

  def step_4_1__rename_models_without_bodies
    CW.parse_dir("04.2-bodies.min", silent: true) do |doc, basename, path|
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

  def step_4_1
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

  def step_5pre__check_some_shit
    results = []
    records = CW.read_hash('04.1-models-other-1')

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

  def step_5_0__load_models
    models = CW.read_hash('04-models-other-2')
    models.shuffle.each do |model|
      filename = model.body_key
      CW.save_ya_page_and_sleep model.url, "05-models-other/#{filename}.html", overwrite: false
    end
  end

  def step_5_1__compress_models
    CW.compress_dir("05.0-models.min", nil, ".b-complectations, .b-car-head, .b-specifications")
  end

  def step_6
    step_6_1__parse_models
  end

  def step_6_1__parse_models
    results = {}
    other_body_urls = {}
    mods = [] # unique mods that should be parsed as is

    CW.parse_dir("05.0-models.min") do |doc, basename, path|
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

    CW.write_data "06.1-mod-urls", results
    CW.write_data "06.1-mod-final", mods
    CW.write_data "06.1-other-body-urls", other_body_urls
  end

  def step_7_0__load_mods
    mods = CW.read_hash('06.1-mod-urls')
    mods.shuffle.each do |key, url|
      CW.save_ya_page_and_sleep url, "07.0-mods/#{key}.html", overwrite: false
    end
  end

  def step_7_1__compress_mods
    CW.compress_dir("07.0-mods", "07-mods.min", ".b-specifications")
  end


  def check_which_marks_have_many_pages
    CW.parse_dir("marks/popular_manual") do |doc, basename, path|
      unless doc.css(".b-tabs__panel_name_cars .b-show-more__button").any?
        puts "REMOVE #{filename}"
        File.delete(filename)
      end
    end
  end
end
