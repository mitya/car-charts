class YA2Processor
  # parses a file with links to model-generation-default-bodytypes
  def step_11
    results = []

    CW.parse_dir("10-models") do |doc, basename, path|
      doc.css("a.b-car").each do |a|
        url_string = a['href']
        url = URI(url_string)
        results << url.path
      end
    end
    
    CW.write_data "11-generation-bodies-first", results
  end
end
