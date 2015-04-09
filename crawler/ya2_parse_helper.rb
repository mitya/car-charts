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
    string = string.strip
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
  def parse_bodytype(mark_key, bodytype_name, silent:true)
    @reductions ||= YAML.load_file("crawler/data-reductions.yml")
    reduction = @reductions['body_body_new'][ "#{mark_key} #{bodytype_name}" ]
    printf "%-20s %30s  %-30s  %20s\n", 'reduce', mark_key, bodytype_name, reduction if reduction unless silent
    bodytype_name = reduction if reduction

    body_key = CWD.bodytypes_by_title[bodytype_name]
    printf "%-20s %30s  %s\n", 'no match', mark_key, bodytype_name if !body_key unless silent
    body_key
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
    brand_name = CWD.adjusted_brand_names[brand_key]
    "#{brand_name} #{model_self_name}"
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
