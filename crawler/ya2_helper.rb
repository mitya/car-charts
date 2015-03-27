module CW
  module_function

  def save_page(url, path, overwrite: true, dir: WORKDIR)
    if !overwrite && File.exist?(dir + path)
      puts "EXIST #{path}" 
      return false
    end
    
    open(url, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20100101 Firefox/35.0") do |page|
      puts "GET #{url} => #{path}"
      write_file(dir + path, page.read)
      # open(dir + path, "w") { |file| file.write(page.read) }
    end
    
    return true
  end
  
  def save_page_and_sleep(url, path, overwrite: true, sleep_interval: 1..3)
    saved = save_page url, path, overwrite: overwrite
    sleep rand(sleep_interval) if saved
  end
  
  def save_ya_page_and_sleep(ya_path, path, overwrite: true)
    save_page_and_sleep YA_HOST + ya_path, path, overwrite: overwrite
  end
  
  def write_file(path, content)
    open(path, "w") { |file| file.write(content) }
  end

  def parse_file(file, silent:false)
    puts "Parsing #{file}" unless silent
    return Nokogiri::HTML(open(file))
  end

  def write_data(filename, data, dir: WORKDIR)
    path = "#{dir}/#{filename}.yaml"

    if data.is_a?(Array)
      data.map! &:to_h if data.first.is_a?(OpenStruct)
      puts "Write #{data.size} items to #{path}"
    end

    open(path, "w") { |f| f.write YAML.dump(data) }
  end

  def write_data_to_json(filename, data, dir = WORKDIR)
    open("#{dir}/#{filename}.json", "w") { |f| f.write JSON.pretty_generate(data) }
  end
  
  def write_csv(data)
    path = "#{WORKDIR}/output.csv"    
    
    if data.is_a?(Array)
      data.map! &:to_h if data.first.is_a?(OpenStruct)
      puts "Write #{data.size} items to #{path}"
    end

    open(path, "w") { |f| f.write data.map { |row| CSV.generate_line(row) }.join }
  end

  def read_hash(filename, dir = WORKDIR)
    return YAML.load( File.read("#{dir}/#{filename}.yaml") ).map { |hash| OpenStruct.new(hash) }
  end
  
  def read_hash_in_json(filename, dir = WORKDIR)
    return JSON.parse File.read("#{dir}/#{filename}.json")
  end
  
  def parse_dir(directory, limit: nil, silent: false)
    count = 0
    sec = Benchmark.realtime do
      Dir.glob(WORKDIR + "#{directory}/*.html").each do |path|
        count += 1
        return if limit && count == limit
        basename = File.basename(path, '.html')
        doc = CW.parse_file(path, silent:silent)
        yield doc, basename, path
      end
    end

    printf "Processed #{count} files in %02d:%02d sec\n", *sec.divmod(60)
  end
  
  def compress_dir(dir, outdir, selectors, limit: nil)
    FileUtils.mkdir_p File.join(WORKDIR, outdir)
    parse_dir(dir, limit: limit) do |doc, basename, path|
      content = doc.css(selectors)
      content.xpath('//@data-bem').remove
      content.xpath('//@style').remove
      
      doc.at_css('body').inner_html = content
      doc.at_css('head').inner_html = ''
    
      new_path = File.join(WORKDIR, outdir, "#{basename}.html")
    
      write_file(new_path, doc.to_html)
    end    
  end

  # def save_plist(data, filename, dir = OUTDIR)
  #   open(dir + "#{filename}.plist", "w") { |file| file.write data.to_plist }
  #   system "plutil -convert binary1 #{dir}/#{filename}.plist"
  # end
  #
  # def convert_to_plist(source, dir = OUTDIR)
  #   items = JSON.load(dir + "#{source}.json")
  #   open(dir + "#{source}.plist", "w") { |file| file.write items.to_plist }
  #   system "plutil -convert binary1 #{OUTDIR}/#{source}.plist"
  # end
  #
  # def escape(string)
  #   string = string.strip
  #   string = string.gsub('+', 'plus')
  #   string.gsub(/[^\w]/, '_').downcase
  # end
  #
  # def print_hash(hash, options = {})
  #   key_len = options[:len] || 25
  #   hash.symbolize_keys!
  #   hash.each do |k,v|
  #     printf %{%#{key_len}s %-s,\n}, "#{k}:", v.inspect
  #   end
  # end
  #
  # def reformat_years(years)
  #   from, to = years.split('–')
  #   to = nil if to == "2012"
  #   years = [from, to].compact.join('-')
  # end
  #
  # def escape_body_key(en_title)
  #   escape en_title.sub(/(\d)-dr/, '\1d')
  # end
  #
  # def translate_body_name(rus)
  #   en = rus.sub(BASE_BODY_TYPES_RE, BASE_BODY_TYPES)
  #   en = en.sub("полуторная кабина", "extended cab")
  #   en = en.sub("двойная кабина", "double cab")
  #   en = en.sub("7 мест", "7 seats")
  #   en = en.sub("5 мест", "5 seats")
  #   en = en.sub("cabrio сс", "cabrio cc")
  #   en = en.sub("sedan 21108 премьер", "sedan 21108")
  #   en = en.sub("+2", "plus 2")
  #   en = en.sub(/(\d) дв/, '\1-dr')
  # end
  #
  # def stats_for_keys(keys)
  #   stats = keys.each_with_object({}) { |e,h| h[e] = h[e].to_i + 1 }
  #   Hash[*stats.sort_by {|k,v| v}.flatten]
  # end
  #
  # def to_i(str)
  #   Integer(str) rescue nil
  # end
  #
  # def to_f(str)
  #   Float(str) rescue nil
  # end
end
