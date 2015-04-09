class YA2Processor
  F11 = "11-models-1pass"
  F11b = "11-models-2pass"
  D12 = "12-mods-pass1n2"

  # compress models
  def step_10m
    dir = '10-models'
    CW.compress_dir(dir, nil, nil, zip: false, hard: false)
  end

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

    CW.write_objects F11, rs.uniq(&:url)
  end

  # this step will should be repeated twice
  def step_12
    CW.read_objects(F11).shuffle.each do |q|
      filename = q.url.split('/').first(4).join(' ').strip
      CW.save_ya_page_and_sleep q.url, "#{D12}/#{ filename }.html", overwrite: false, test: true
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

  def step_12b
    CW.read_data(F11b).each do |url|
      filename = url.split('/').first(4).join(' ').strip
      CW.save_ya_page_and_sleep url, "#{ D12 }/#{ filename }.html", overwrite: false
    end
  end


  def step_12m
    CW.compress_dir(D12, nil, ".b-complectations, .b-specifications, .car-head, .catalog-filter", zip: false)
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
  # work on 10, 12, 14
  def step_12css
    dir = D12
    # dir = "10-models"
    Dir.glob(WORKDIR + "#{dir}/*.html") do |path|
      text = File.read(path)
      pattern = /"[\w\.\/-]+_common.css"/
      puts path if text =~ pattern
      text.sub!(pattern, '"../_shared/_common.css"')
      CW.write_file(path, text)
    end
  end
end
