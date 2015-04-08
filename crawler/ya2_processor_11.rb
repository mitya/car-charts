class YA2Processor
  FIL_11 = "11-generation-bodies-first"
  DIR_12 = "12-generation-bodies-first"
  FIL_13 = "13-generation-bodies-other"
  DIR_14 = "14-generation-bodies-other"
  
  
  # parses a file with links to model-generation-default-bodytypes
  def step_11
    results = []

    CW.parse_dir("10-models") do |doc, basename, path|
      doc.css("a.b-car").each do |a|
        results << URI(a['href']).path + '/specs'
      end
    end
    
    CW.write_lines FIL_11, results.uniq
  end
  
  def step_12
    CW.read_lines(FIL_11).shuffle.each do |path, data|
      CW.save_ya_page_and_sleep path, "#{DIR_12}/#{ path.split('/').join(' ').strip }.html", overwrite: false
    end    
  end
  
  # parse initial bodytypes to extract other bodytypes URLs
  def step_13
    results = []
    CW.parse_dir(DIR_12) do |doc, basename, path|
      doc.css(".bodytypes a.link").each do |a|
        results << URI(a['href']).path
      end
    end
    CW.write_lines FIL_13, results
  end
  
  def step_14
    CW.read_lines(FIL_13).shuffle.each do |path, data|
      CW.save_ya_page_and_sleep path, "#{DIR_14}/#{ path.split('/').join(' ').strip }.html", overwrite: false
    end    
  end
  
  # optional: inject local css
  def step_121   
    Dir.glob(WORKDIR + "#{DIR_14}/*.html") do |path|
      text = File.read(path)
      text.sub!('//yastatic.net/auto2/4.0-23/pages-desktop/common/_common.css', '../_shared/_common.css')
      CW.write_file(path, text)
    end
  end
  
  # compress
  def step_122
    CW.compress_dir(DIR_14, nil, ".b-complectations, .b-specifications, .car-head, .catalog-filter", zip: false)
  end
end
