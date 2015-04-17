module CW
  module_function

  def to_i(str, zero: false)
    return nil if (str == '' || str == nil) & zero
    str.to_i
  end

  def to_f(str)
    # Float(str) rescue nil
    str.to_f
  end
  
  def stringify_keys(hash)
    hash = hash.to_h if hash.is_a?(OpenStruct)
    hash.keys.each { |k| hash[k.to_s] = hash.delete(k) if k.is_a?(Symbol) }
    hash
  end
  
  def escape(string)
    string = string.gsub('+', 'plus')
    string.gsub(/[^\w]/, '_').downcase
  end

  def blank?(val)
    val == nil || val == '' || val == 0
  end

  # Momentum 1.6 AMT (150 л.с.) передний привод, бензин => 1.6i-150ps-AMT-FWD
  # sDrive30i 3.0 AT (258 л.с.) задний привод, бензин
  # 1.4 MT (125 л.с.) передний привод, бензин
  # 4.4 AT (540 л.с.)
  def parse_ya_aggregate_title(title)
    title = title.strip
    re = /(\d\.\d) (\w{2,3}) \((\d+) л\.с\.\) (\p{L}+) привод, ([\p{L}\s\/]+)$/
    volume, transmission, power, drive, fuel = title.scan(re).flatten
    transmission_key = transmission
    drive_key = CWD.translations(:drive, drive)
    fuel_key = CWD.translations(:fuel, fuel)
    "#{volume}#{fuel_key}-#{power}ps-#{transmission_key}-#{drive_key}"
  end
  
  # :opel, хэтчбэк 5 дв => hatch5d
  # :mercedes, седан AMG Long => sedan_long
  # :mercedes, черти-что => nil
  def parse_bodytype(mark_key, model_key, bodytype_name, silent:true)
    silent = false

    if body_key = Info.bodytypes_by_title[bodytype_name]
      [body_key, body_key, nil, nil]
    elsif reduction = Info.data_reductions['custom_bodytypes']["#{mark_key} #{model_key} #{bodytype_name}"]      
      body_base_key, body_version_key, body_version_name = reduction
      if body_version_key
        body_key = "#{body_base_key}.#{body_version_key}"
        # puts "reduce #{mark_key} #{model_key} #{body_key}" if reduction unless silent
        [body_key, body_base_key, body_version_key, body_version_name]
      else
        [body_base_key, body_base_key, nil, nil]
      end
    else
      puts "no match for #{mark_key} #{model_key} #{bodytype_name}" if body_key == nil unless silent
      []
    end
  end
  
  def build_reductions_table_template
    # "хэтчбек 5 дв Sportback" => "hatch_5d Sportback"
    # key__bodytype_name = bodytype_name.sub(Info.bodytype_default_titles_pattern) { |match| Info.bodytypes_by_title[match] }
    # body_base_key, body_version_name = key__bodytype_name.split(' ', 2)
    # body_version_key = escape(body_version_name)
    # puts "#{mark_key} #{model_key} #{bodytype_name}: [#{bodykey}, #{bodyversion}, #{title}]"    
  end
  
  # "2014 – 2015" => 2014
  # "2014" => 2014
  # "" => nil
  def parse_first_year(string)
    result = string.to_s.split(' – ').first    
    result = result.to_i if result
    result    
  end
  
  # "2014 – 2015" => 2014
  # "2014" => 2014
  # "" => nil
  def parse_years(string)
    first, last = string.to_s.split(' – ')
    [first, last].reject(&:nil?).map(&:to_i)
  end
  
  # 2993 => '3.0'
  def make_displacement_key(displacement)
    "%.1f" % (displacement.to_f / 1000)
  end
  
  # {mod hash} => alfa_romeo giulietta 2010 hatch_5d 2.0d-150ps-MT-FWD
  def build_key_from_mod(m)
    m = OpenStruct.new(m)
    mark, model = m['generation_key'].split('--')
    aggregate = aggregate_key(m.displacement_key, m.fuel, m.max_power, m.transmission, m.drive)
    
    [mark, model, m.year, m.body, aggregate].join(' ')
  end

  def aggregate_key(displacement, fuel, power, transmission, drive)
    displacement_and_fuel = [displacement, fuel].compact.join
    aggregate = [displacement_and_fuel, "#{power}ps", transmission, drive].join('-')
  end
  
  def bm(label = "Action", &block)
    s = Time.now
    result = yield
    puts "#{label} took: #{Time.now - s}s"
    result
  end
  
  def profile_start
    @time = Time.now
  end
  
  def profile
    puts "time: #{Time.now - @time}s"
    @time = Time.now
  end  

  def convert_space_key_to_dash_key(key)
    mark, model, year, body, engine = key.split
    old_model_key = [mark, model, year, body].join('-')
    old_key = [ old_model_key, engine ].join('--')
  end

  def convert_dash_key_to_space_key(key)
    model_key, engine = key.split('--')
    mark, model, year, body = model_key.split('-')
    [mark, model, year, body, engine].join(' ')
  end
  
  # Lada (ВАЗ) Kalina => Lada Kalina
  # BMW X5 => BMW X5
  # That's about converting Lada, UAZ & Moskvitch brand names to English
  def build_internal_branded_model_name(brand_key, model_self_name)
    brand_name = Info.adjusted_brand_names[brand_key]
    "#{brand_name} #{model_self_name}"
  end  
  
  def build_model_name(mark, model, yandex_mark_model_name)
    result = Info.data_reductions['renamed_models']["#{mark} #{model}"]
    return result if result
  
    short_brand_name = Info.yandex_short_brand_names[mark]
    puts "ERROR: Unknown brand #{mark}" if short_brand_name == nil
    
    result = yandex_mark_model_name.sub "#{short_brand_name} ", '' # Ford Focus => Focus
    result.sub!(/\s+\(.*\)$/, '') # remove everything in (...)
    result.sub!('-klasse', '-Class') if mark == 'mercedes'
    result
  end
  
  def assert_all(array, except:nil)
    array.each_with_index { |item, index| assert_exist(item) unless except == index }
    array
  end
  
  def assert_exist(value)
    puts "Blank value detected: #{value.inspect}" if value == nil || value == 0 || value.is_a?(String) && value.empty?
    value
  end
end

class Mash
  attr_accessor :hash
  
  def initialize(hash = {})
    @hash = hash
  end
  
  def [](key)
    @hash[key.to_s]
  end
  
  def []=(key, value)
    @hash[key.to_s] = value
  end
  
  def method_missing(method, *args, &block)
    return @hash.send(method, *args, &block) if HASH_METHODS.include?(method)
    
    method = method.to_s
    case method when /(\w+)=/
      @hash[$1] = args.first
    else
      @hash[method]
    end
  end
  
  def inspect
    "Mash#{hash.inspect}"
  end
  
  HASH_METHODS = Set.new(Hash.instance_methods - [:key, :count])
end

class Hash
  def mash
    Mash.new(self)
  end
  
  def map_values(&block)
    each do |k, v|
      self[k] = yield v
    end
  end
end

class Array  
  def index_by(&block)
    hash = {}
    each do |item|
      key = yield item
      # p key
      hash[key] = item
    end
    hash
  end  
end

W = CW
