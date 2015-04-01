module CW
  module_function

  def save_page(url, path, overwrite: true, dir: WORKDIR, test: false)
    if test
      puts "WILL WRITE #{path}" unless File.exist?(dir + path)
      return false
    end
    
    if !overwrite && File.exist?(dir + path)
      puts "EXIST #{path}" 
      return false
    end
    
    open(url, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20100101 Firefox/35.0") do |page|
      puts "GET #{url} => #{path}"
      write_file(dir + path, page.read)
    end
    
    return true
  end
  
  def save_page_and_sleep(url, path, overwrite: true, sleep_interval: 1..3, test: false)
    saved = save_page url, path, overwrite: overwrite, test: test
    sleep rand(sleep_interval) if saved
  end
  
  def save_ya_page_and_sleep(ya_path, path, overwrite: true, test: false)
    save_page_and_sleep YA_HOST + ya_path, path, overwrite: overwrite, test: test
  end
  
  def write_file(path, content)
    open(path, "w") { |file| file.write(content) }
  end

  def write_data(filename, data, dir: WORKDIR)
    path = "#{dir}/#{filename}.yaml"

    if data.is_a?(Array)
      data.map! &:to_h if data.first.is_a?(OpenStruct)      
    end
    
    puts "Write #{data.size if data.respond_to?(:size)} items to #{path}"

    open(path, "w") { |f| f.write YAML.dump(data) }
  end

  def write_data_to_json(filename, data, dir = WORKDIR)
    open("#{dir}/#{filename}.json", "w") { |f| f.write JSON.pretty_generate(data) }
  end
  
  def write_data_to_plist(filename, data, dir: WORKDIR)
    open(dir + "#{filename}.plist", "w") { |file| file.write data.to_plist }
    system "plutil -convert binary1 #{dir}/#{filename}.plist"
  end
  
  def write_data_to_binary(filename, data, dir: WORKDIR)
    open("#{dir}/#{filename}.bin", "w") { |f| f.write Marshal.dump(data) }
  end
  
  def write_csv(data)
    path = "#{WORKDIR}/output.csv"    
    
    if data.is_a?(Array)
      data.map! &:to_h if data.first.is_a?(OpenStruct)
      puts "Write #{data.size} items to #{path}"
    end

    open(path, "w") { |f| f.write data.map { |row| CSV.generate_line(row) }.join }
  end

  def read_hash(filename, dir = WORKDIR, openstruct:true)
    data = YAML.load( File.read("#{dir}/#{filename}.yaml") )
    if openstruct
      case data
      when Array 
        data.map { |hash| OpenStruct.new(hash) }
      when Hash        
        data.each { |k, h| data[k] = OpenStruct.new(h) }
        data
      end
    else
      data
    end
  end
  
  def read_hash_in_json(filename, dir = WORKDIR)
    return JSON.parse File.read("#{dir}/#{filename}.json")
  end
  
  def read_data_in_binary(filename, dir: WORKDIR)
    open("#{dir}/#{filename}.bin") { |f| Marshal.load(f) }
  end

  def parse_file(file, silent:false)
    puts "Parsing #{file}" unless silent
    return Nokogiri::HTML(open(file))
  end
    
  def parse_dir(directory, limit: nil, silent: false, only: nil)
    count = 0
    sec = Benchmark.realtime do
      pattern = if only
        '{' + only.join(',') + '}'
      else
        '*'
      end
      Array(directory).each do |dir|
        Dir.glob("#{WORKDIR + dir}/#{pattern}.html").each do |path|
          count += 1
          return if limit && count == limit
          basename = File.basename(path, '.html')
          doc = CW.parse_file(path, silent:silent)
          yield doc, basename, path
        end
      end
    end

    printf "Processed #{count} files in %02d:%02d sec\n", *sec.divmod(60)
  end
  
  def compress_dir(dir, outdir, selectors, limit: nil, zip: true)
    outdir = dir unless outdir
    FileUtils.mkdir_p File.join(WORKDIR, outdir)
    if zip
      puts "compressing #{WORKDIR + dir}"
      system "tar cjf #{WORKDIR + dir}.tbz -C #{WORKDIR + dir} ."
    end
    parse_dir(dir, limit: limit) do |doc, basename, path|
      content = doc.css(selectors)
      content.xpath('//@data-bem').remove
      content.xpath('//@style').remove
      content.xpath('//img').remove
      
      doc.at_css('body').inner_html = content
      doc.at_css('head').inner_html = ''
    
      new_path = File.join(WORKDIR, outdir, "#{basename}.html")
    
      write_file(new_path, doc.to_html)
    end    
  end  
  
  def load_dataset(name)
    YAML.load_file("crawler/data-#{name}.yml")
  end
end
