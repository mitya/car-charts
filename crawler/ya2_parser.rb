# Parses mods pages
#
# Оценка безопасности не распарсена так как она не представлена в текстовом виде
#
#
# dir(07-mods-stripped) => step_8_1__html_to_hashes_with_en_keys => file(08.1-mods.yaml)
# file(08.1-mods.yaml) => step_8_2__parse_mod_values => file(08.2-mods.yaml) & file(08.2-mods.plist)
#
class YA2Parser
  SPACE_RE = %r{\s+}
  NON_ZERO_KEYS = [:consumption_city, :consumption_highway, :consumption_mixed, :gears, :ground_clearance, :bore, :luggage_min, :luggage_max].to_set

  def step_8
    step_8_1
    step_8_2
    step_8_3
  end

  def step_8_1 # parse mods to raw
    results = {}

    parser = lambda do |doc, basename, path|
      result = results[basename] = {}

      doc.css(".b-specifications__details .b-features__item_type_specs").each do |div|
        name = div.at_css(".b-features__name").text
        name_translation = TranslationHelper.instance.translate_parameter(name)
        value = div.at_css(".b-features__value").text.strip

        puts "TRANSLATION MISSING: #{name}" unless name_translation
        result[name_translation.to_s] = value
      end
    end

    CW.parse_dir("07.0-mods", &parser)

    unique_mod_keys = CW.read_hash "06.1-mods-singles", openstruct: false
    unique_mod_keys.each do |basename|
      path1 = WORKDIR + "04.4-bodies-renamed" + "#{basename}.html"
      path2 = WORKDIR + "04.6-bodies-other" + "#{basename}.html"
      path = File.exist?(path1) ? path1 : path2
      doc = CW.parse_file(path, silent: true)
      parser.call(doc, basename.split(' ').join('-'), path)
    end

    CW.write_data "08.1-mods", results
  end

  def step_8_2 # parse mod values
    raw_mods = CW.read_hash('08.1-mods', openstruct: false)
    parsed_mods = {}

    raw_mods.first(1_000_000).each do |mod_key, properties|
      parsed = {}

      properties.each do |key, string|
        case key.to_sym
        when :front_suspension, :rear_suspension, :front_brakes, :rear_brakes, :model_title, :body_title, :body_type, :price, :engine_title, :engine_spec, :category,
              :safety_rating_value, :safety_rating_name, :injection
        when :fuel_consumption
          values = string.split(%r{ / }).map { |str| CW.to_f(str) }
          parsed[:consumption_city], parsed[:consumption_highway], parsed[:consumption_mixed] = values
        when :bore_and_stroke
          values = string.split(' × ').map { |str| CW.to_f(str) }
          parsed[:bore], parsed[:stroke] = values
        when :max_power # 201 / 148 при 6800  ||  201 / 148 при 6800 – 7000
          values = string.scan(%r{(\d+) / (\d+)(?: при (\d+)(?: – (\d+))?)?}).first
          values.map! { |s| CW.to_i(s) }
          parsed[:max_power], parsed[:max_power_kw], parsed[:max_power_range_start], parsed[:max_power_range_end] = values
        when :max_torque # 600 при 3000 – 4000  ||  600 при 3000
          values = string.scan(%r{(\d+)(?: при (\d+)(?: – (\d+))?)?}).first
          values.map! { |s| CW.to_i(s) }
          parsed[:max_torque], parsed[:max_torque_range_start], parsed[:max_torque_range_end] = values
        when :tires
          parsed[:tires] = string.split(%r{\s}).each_slice(5).map { |items| items.join }.join(' ')
        when :luggage_capacity
          values = string.split(SPACE_RE).map { |str| CW.to_i(str) }
          parsed[:luggage_min], parsed[:luggage_max] = values.first, values.last
        when :seats
          string = '4' if string == '2+2'
          values = string.split(SPACE_RE).map { |str| CW.to_i(str) }
          parsed[:seats_min], parsed[:seats_max] = values.first, values.last
        when :brand_country
          parsed[:brand_country] = TranslationHelper.instance.russian_country_title_to_code(string)
        when :assembly_country
          names = string.split(%r{,\s+})
          names.map! { |rus_name| TranslationHelper.instance.russian_country_title_to_code(rus_name) }
          parsed[:assembly_countries] = names.join(' ')
        when :produced_since, :produced_till
          if string.length > 4
            month, year = string.split(SPACE_RE)
            month_number = Rus_Months.index(month) + 1
            parsed[key] = year.to_i * 100 + month_number
          elsif string.length == 4
            parsed[key] = string.to_i * 100
          end
        when :top_speed, :displacement, :cylinder_count, :cylinder_valves, :gears, :max_power, :max_power_kw, :max_torque,
              :max_power_revs, :max_torque_revs, :length, :width, :height, :ground_clearance, :front_tire_rut, :rear_tire_rut,
              :wheelbase, :luggage_capacity, :tank_capacity, :kerbweight, :gross_mass, :doors, :co2_emission
          parsed[key] = CW.to_i(string)
        when :acceleration_100kmh, :bore, :stroke, :compression, :displacement_key
          parsed[key] = CW.to_f(string)
        when :cylinder_placement, :engine_layout, :front_suspension, :rear_suspension,
              :front_brakes, :rear_brakes, :fuel, :fuel_rating, :transmission, :drive, :compressor
          parsed[key] = TranslationHelper.instance.translate_value(key, string)
        when :eco_class
          parsed[key] = string
        else
          parsed["__#{key}"] = string
        end
      end

      # replace dashes with spaces in the key
      new_key = ModKey.from_dash_key(mod_key)

      # store key parts as individual elements
      parsed['body'] = new_key.body
      parsed['model_key'] = new_key.brand_and_model
      parsed['version_key'] = new_key.version
      parsed['year'] = CW.to_i(new_key.years, zero: false)
      parsed['displacement_key'] = new_key.displacement || CW.make_displacement_key(parsed['displacement'])

      # convert all keys to strings
      parsed.keys.each { |k| parsed[k.to_s] = parsed.delete(k) }

      # remove nil values because plists can't contain it
      parsed.delete_if { |k, v| v.nil? }

      # replace zeros with nils for some keys
      parsed.each { |k, v| parsed.delete(k) if v == 0 && NON_ZERO_KEYS.include?(k) }

      parsed_mods[new_key.to_s_with_spaces] = parsed
    end

    parsed_mods_arrays = {}
    parsed_mods.each do |mod_key, mod_hash|
      parsed_mods_arrays[mod_key] = CWD.used_fields.each_with_index.map { |k, i| mod_hash[k] || '' }
    end

    xvalidate do
      parsed_mods.each_with_object({}) do |(mod_key, hash), result|
        hash.each do |attr_key, val|
          if CW.blank?(val)
            result[attr_key] ||= 0
            result[attr_key] += 1
          end
        end
      end.sort_by { |k, v| v }.each do |key, count| printf "%25s %4i\n", key, count end

      puts

      parsed_mods_arrays.each_with_object({}) do |(mod_key, array), result|
        array.each_with_index do |val, index|
          if CW.blank?(val)
            result[CWD.used_fields[index]] ||= 0
            result[CWD.used_fields[index]] += 1
          end
        end
      end.sort_by { |k, v| v }.each do |key, count| printf "%25s %4i\n", key, count end        
    end
    
    CW.write_data_to_plist "08.2-mods", parsed_mods_arrays
    CW.write_data "08.2-mods", parsed_mods
    
    CW.write_data_to_plist "debug-08.2-mods.kv", parsed_mods.first(20).to_h
    CW.write_data "debug-08.2-mods.sample", parsed_mods.first(20).to_h
  end

  def step_8_3 # build metadata
    models = CW.read_hash('03.0-models', openstruct: true)
    mods = CW.read_hash('08.2-mods', openstruct: false)
    model_keys = mods.map { |key, mod| mod['model_key'] }.uniq.sort
    brand_keys = mods.map { |key, mod| key.split.first }.uniq.sort
    model_keys_set = model_keys.to_set

    model_infos = model_keys.each_with_object({}) do |key, result| # { 'bmw--x6' =>  ['X6', 'BMW X6', 'bmw', 'Xe'], ... }
      model = models[key]
      result[key] = [ model.title, model.full_title, model.mark, CWD.model_classification[key] || '' ]
    end

    models_by_brand = model_keys.each_with_object({}) do |key, result|
      model = models[key]
      (result[model.mark] ||= []) << key
    end

    models_by_class = CWD.model_classification.each_with_object({}) do |(key, klass), result|
      xputs "unused classification key: #{key}" if klass && !model_keys_set.include?(key)
      next unless model_keys_set.include?(key)
      next unless klass
      (result[klass] ||= []) << key
    end

    brand_names = YAML.load_file("crawler/data-brands.yml")['brands']
    brand_names.delete_if { |key, name| !brand_keys.include?(key) }

    metadata = {}
    metadata['model_keys'] = model_keys.sort
    metadata['model_info'] = model_infos
    metadata['models_by_class'] = models_by_class
    metadata['models_by_brand'] = models_by_brand
    metadata['parameters'] = CWD.used_fields
    metadata['brand_names'] = brand_names

    CW.write_data_to_plist "08.3-metadata", metadata
  end

  def print_model_keys
    models = CW.read_hash('03-models', openstruct: true)
    mods = CW.read_hash('08.2-mods', openstruct: false)
    model_keys = mods.map { |key, mod| mod['model_key'] }.uniq.sort
    unused_model_keys = models.keys - model_keys

    model_keys.each { |k| puts k }
  end

  class ModKey
    attr_accessor :brand, :model, :years, :body, :aggregate
    attr_accessor :version
    attr_accessor :engine, :power, :transmission, :drive

    def initialize(attrs = {})
      attrs.each { |k,v| send("#{k}=", v) }
    end

    def to_s_with_spaces
      [brand, model, years, body, aggregate].join(' ').strip
    end

    def displacement
      engine[0..-2] if engine
    end

    def brand_and_model
      [brand, model].join('--')
    end

    def model_and_version
      [model, version].join('.')
    end

    def inspect
      to_s_with_spaces
    end

    #  in: alfa_romeo-giulietta-2010-hatch_5d--1.4i-170ps-MT-FWD
    # out: alfa_romeo giulietta 2010 hatch_5d 1.4i-170ps-MT-FWD
    def self.from_dash_key(old_key)
      model_years_body, aggregate = old_key.split('--')
      brand, model, years, body = model_years_body.split('-')
      engine, power, transmission, drive = aggregate.split('-') if aggregate

      # years.gsub!('_', '-')
      # puts years if years.include?('_')
      #
      # branded_body = "#{brand}--#{body}"
      # branded_model_body = "#{brand}--#{model}--#{body}"
      #
      # body = Reductions_Body_Body[branded_body]
      # puts body if Reductions_Body_Body[branded_body]
      #
      # if body_key_and_model_name = Reductions_Body_Model[branded_body]
      #   puts body_key_and_model_name
      #   body, model_name = body_key_and_model_name.split(' ', 2)
      #   model = CW.escape(model_name)
      # end
      #
      # if body_key_and_version_name = Reductions_Body_Version[branded_model_body]
      #   puts body_key_and_version_name
      #   body, version = body_key_and_version_name.split(' ', 2)
      #   model = "#{model}.#{CW.escape(version)}"
      # end

      new(brand: brand, model: model, years: years, body: body, aggregate: aggregate, engine:engine, power:power, transmission:transmission, drive:drive)
    end

    def self.parse_new_key(key)
      brand, model_and_version, years, body, agregate = key.split(' ')
      model, version = model_and_version.split('.')
      # engine, power, transmission, drive = agregate.split('-')
      new(brand: brand, model: model, years: years, body: body, version: version, aggregate: aggregate)
    end
  end

  class TranslationHelper
    def self.instance
      @instance ||= new
    end

    def initialize
      @data = YAML.load_file("crawler/data-translations.yml")
      @parameters = @data['parameters'].invert

      @values = @data['values']
      @values.each do |k, hash|
        @values[k] = hash.invert
      end

      @countries = YAML.load_file("crawler/data-other.yml")['country_code_to_russian'].invert
    end

    def translate_parameter(russian_name)
      @parameters[russian_name.strip]
    end

    def translate_value(category, russian_name)
      @values[category][russian_name.strip]
    end

    def russian_country_title_to_code(russian_name)
      @countries[russian_name]
    end
  end
end
