class YA2Processor
  F11 = "11-models-1pass"
  F11b = "11-models-2pass"
  D12 = "12-mods-pass1n2"

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
  
  # parse initial bodytypes to extract other bodytypes URLs
  # run after s12
  def step_11b
    results = []
    CW.parse_dir(D12) do |doc, basename, path|
      doc.css(".bodytypes a.link").each do |a|
        results << URI(a['href']).path
      end
    end
    CW.write_lines F11b, results.uniq
  end
  
  # this step will should be repeated twice 
  def step_12
    CW.read_objects(F11).shuffle.each do |q|
      CW.save_ya_page_and_sleep q.url, "#{D12}/#{ q.url.split('/').first(3).join(' ').strip }.html", overwrite: false
    end    
  end

  def step_12b
    CW.read_lines(F11b).each do |url|
      filename = url.split('/').first(4).join(' ').strip
      CW.save_ya_page_and_sleep url, "#{ D12 }/#{ filename }.html", overwrite: false
    end    
  end
  
  # optional: inject local css
  # work on 12 and 14
  def step_121   
    Dir.glob(WORKDIR + "#{D12}/*.html") do |path|
      text = File.read(path)
      text.sub!('//yastatic.net/auto2/4.0-23/pages-desktop/common/_common.css', '../_shared/_common.css')
      CW.write_file(path, text)
    end
  end
  
  # compress
  def step_122
    CW.compress_dir(D12, nil, ".b-complectations, .b-specifications, .car-head, .catalog-filter", zip: false)
  end
end
