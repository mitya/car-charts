class YA2Processor
  include CW
  
  # parses a file with links to model-generation-default-bodytypes
  def step_11
    rs = []

    CW.parse_dir(D10) do |doc, basename, path|
      doc.css("a.b-car").each do |a|
        r = Mash.new
        r.title = a.css_text(".b-car__title")
        r.years = a.css_text(".b-car__year-range")
        r.url = URI(a['href']).path + '/specs'
        r.ya_generation_id = r.url.split('/')[3].to_i
  
        rs << r
      end
    end

    CW.write_objects F11, rs.uniq(&:url)
  end

  # this step should be repeated twice
  def step_12
    case ENV['pass'] 
    when '1'
      models = CW.read_objects(F11)
      models.reject! { |model| model.years.split(' – ').first.to_i < 2005 }
      urls = models.map(&:url)
    when '2'
      urls = CW.read_data(F11b)
    else
      puts "specify pass: 1 or 2"
      exit
    end
    
    urls.shuffle.each do |url|
      filename = url.split('/').first(4).join(' ').strip
      CW.save_ya_page_and_sleep url, "#{D12}/#{ filename }.html", overwrite: false
    end
  end

  # parse initial bodytypes to extract other bodytypes URLs
  # run after s12
  def step_11b
    results = []
    CW.parse_dir(D12) do |doc, basename, path|
      doc.css(".bodytypes a.link").each do |a|
        results << URI(a['href']).path
      end
    end
    CW.write_data F11b, results.uniq
  end

  D12_ONLY = [] #['audi']
  def step_13
    seq11 = read_objects(F11)
    seq11_index = seq11.index_by(&:ya_generation_id)
    models = []
    
    parse_dir(D12, silent: true, only: D12_ONLY) do |doc, basename, path|
      parts = basename.split
      mark_model = parts.first(2).join(' ')
      
      next if Info.data_reductions['rejected_models'].include?(mark_model)
      
      mark_model_bodytype = doc.css_text("title").split(' | ').first
      url = doc.at_css('.heading a.link')['href']
      
      model = Mash.new
      model.path = path.sub(WORKDIR.to_s, '')
      model.mark = parts[0]
      next if SHIT.include?(model.mark)

      model.model = parts[1]
      model.yandex_id = parts[2].to_i
      model.yandex_key = basename
      model.yandex_title = doc.css_text(".car-head h1")
      model.yandex_generation = doc.css_text(".generations button .button__text")
      model.yandex_bodytype = mark_model_bodytype.sub model.yandex_title + ' ', '' # ".bodytypes button .button__text"
      model.url = url

      bodytypes = parse_bodytype(model.mark, model.model, model.yandex_bodytype, silent: true)
      model.bodytype, model.bodytype_base, _, model.bodytype_version = bodytypes
      next if model.bodytype == nil

      years = doc.css_text(".generations button .button__text") || seq11_index[model.yandex_id].years
      model.year, model.year_end = parse_years(years)
      next unless model.year >= MIN_START_YEAR || model.year_end && model.year_end >= MIN_END_YEAR

      # this doesn't handle the case when a model has a few complectations but just one engine, thus that a single
      # e.g. bmw x6_m 2009 crossover, subaru b9_tribeca 2007 crossover
      model.count = doc.css(".b-complectations__item:not(.b-complectations__item_state_current) a.link").count
      model.count = 1 if model.count == 0
      
      model.key = [model.mark, model.model, model.year, model.bodytype].join(' ').strip
      
      model.model_title = build_model_name(model.mark, model.model, model.yandex_title)
      model.title = build_internal_branded_model_name model.mark, model.model_title
      
      models << model
    end

    write_objects F13, models 
    write_objects "debug-#{F13}-keys", models.map(&:key)
  end
  
  # ensure that files contain what the title says
  def step_12bad
    CW.parse_dir(D12, silent: true) do |doc, basename, path|
      link = doc.at_css('.heading a.link')
      parts = link['href'].split('/')
      content_id = parts[3]   
      file_id = basename.split[2]
      if file_id != content_id
        p [basename, content_id, File.size(path), File.size(path.sub(file_id, content_id))] 
        # File.delete(path)
      end
    end
  end

  # optional: inject local css
  # work on 10, 12, 18
  def step_10css
    dir = D10
    # dir = D18
    Dir.glob(WORKDIR + "#{dir}/*.html") do |path|
      text = File.read(path)
      pattern = /"[\w\.\/-]+_common.css"/
      puts path if text =~ pattern
      text.sub!(pattern, '"../_shared/_common.css"')
      CW.write_file(path, text)
    end
  end

  # compress models
  def step_10strip
    # CW.compress_dir(D10, nil, nil, zip: false, hard: false) # for listing
    # CW.compress_dir(D12, nil, ".b-complectations, .b-specifications, .car-head, .catalog-filter", zip: false) # for mods & models
    CW.compress_dir(D18, nil, ".b-complectations, .b-specifications, .car-head, .catalog-filter", zip: false) # for mods & models
  end
  
  def step_10t
    # models = W.read_objects(F13)
    # rows = models.map { |model| [model.key, "#{model.mark}--#{model.model}", model.title, model.model_title] }
    # write_html rows
  end
end
