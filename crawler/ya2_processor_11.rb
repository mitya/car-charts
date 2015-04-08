class YA2Processor
  FIL_11 = "11-generation-bodies-1pass"
  DIR_12 = "12-generation-bodies"
  FIL_13 = "13-generation-bodies-other"
  FIL_15 = "15-models"
  FIL_16 = "16-models"
  
  # parses a file with links to model-generation-default-bodytypes
  def step_11
    rs = []

    CW.parse_dir("10-models") do |doc, basename, path|
      doc.css("a.b-car").each do |a|
        r = Mash.new
        r.title = a.css_text(".b-car__title")
        r.years = a.css_text(".b-car__year-range")
        r.url = URI(a['href']).path + '/specs'
        r.ya_generation_id = r.url.split('/')[3].to_i
        rs << r       
      end
    end
    
    CW.write_objects FIL_11, rs.uniq(&:url)
  end
  
  # this step will should be repeated twice 
  def step_12
    CW.read_objects(FIL_11).shuffle.each do |q|
      CW.save_ya_page_and_sleep q.url, "#{DIR_12}/#{ q.url.split('/').first(3).join(' ').strip }.html", overwrite: false
    end    
  end
  
  # parse initial bodytypes to extract other bodytypes URLs
  def step_11b
    results = []
    CW.parse_dir(DIR_12) do |doc, basename, path|
      doc.css(".bodytypes a.link").each do |a|
        results << URI(a['href']).path
      end
    end
    CW.write_lines FIL_13, results
  end
  
  # some models will have no generation
  def step_15
    rs = []    
    CW.parse_dir(DIR_12) do |doc, basename, path|
      mark_model_bodytype = doc.css_text("title").split(' | ').first

      r = Mash.new
      r.key = basename
      r.title = doc.css_text(".car-head h1")
      r.generation = doc.css_text(".generations button .button__text")
      r.bodytype = mark_model_bodytype.sub r.title + ' ', '' # ".bodytypes button .button__text"
      r.mods = doc.css_count(".b-complectations__item:not(.b-complectations__item_state_current) a.link")
        
      rs << r.hash
    end
    CW.write_data(FIL_15, rs)
  end
  
  def step_16
    seq15 = CW.read_objects(FIL_15)
    seq11 = CW.read_objects(FIL_11)
    seq11_index = seq11.group_by(&:ya_generation_id)    
    seq16 = seq15.map do |q|
      w = Mash.new

      parts = q.key.split
      w.mark = parts[0]
      w.model = parts[1]
      w.yandex_id = parts[2].to_i
      
      years = q.generation
      years = seq11_index[w.yandex_id].first.years unless years
      w.year, w.year_end = CW.parse_years(years)
      
      w.bodytype = CW.parse_bodytype(w.mark, q.bodytype, silent: true)
      next unless w.bodytype
      
      w
    end.compact
    CW.write_objects FIL_16, seq16
  end

  def step_16v
    seq = CW.read_objects(FIL_16)
    seq.reject! { |q| SHIT.include?(q.mark) }
    # seq.select! { |q| q.bodytype == nil }
    seq.each do |q|
      printf "%-40s %-40s %-40s %-40s %-4s\n", q.key, q.title, q.bodytype, q.generation, q.mods
    end
    puts seq.count
  end
  
  def step_152
    rs = []
    CW.parse_dir(DIR_12) do |doc, basename, path|
      mark = basename.split(' ').first
      next if SHIT.include?(mark)      
      doc.css(".b-complectations__item:not(.b-complectations__item_state_current) a.link").each do |a|
        rs << a['href']
      end
    end
    rs = rs.sort.uniq
    CW.write_data(FIL_15, rs)
  end
  
  
  # load mods
  def step_19
    rs = []
    CW.read_data(FIL_15).each do |url|
      components = url.split('/')
      mark = components[1]
      model = components[2]
      generation_id = components[3]
      generation_complectation_engine_id = components[5]
      engine_id = generation_complectation_engine_id.split('_').last
      name = [mark, model, generation_id, engine_id].join(' ')
      rs << name
      puts name
      # CW.save_ya_page_and_sleep path, "#{DIR_14}/#{ path.split('/').join(' ').strip }.html", overwrite: false
    end    
    p rs.count
    p rs.uniq.count
  end
  
  # optional: inject local css
  # work on 12 and 14
  def step_121   
    Dir.glob(WORKDIR + "#{DIR_12}/*.html") do |path|
      text = File.read(path)
      text.sub!('//yastatic.net/auto2/4.0-23/pages-desktop/common/_common.css', '../_shared/_common.css')
      CW.write_file(path, text)
    end
  end
  
  # compress
  def step_122
    CW.compress_dir(DIR_12, nil, ".b-complectations, .b-specifications, .car-head, .catalog-filter", zip: false)
  end

  def step_99
    Dir.glob(WORKDIR + "#{DIR_12}/*specs.html").each do |path|
      newname = path.sub(' specs.html', '.html')
      FileUtils.mv(path, newname)
    end
  end

  SHIT = Set.new %w(ac ariel bronto bufori byvin caterham changfeng coggiola dadi e_car ecomotors foton fuqi gonow gordon hafei haima haval hawtai
    hindustan holden huanghai invicta iran_khodro liebao landwind lti mahindra marlin maruti morgan noble pagani panoz pgo panoz
    mitsuoka puch qoros spyker)
end
