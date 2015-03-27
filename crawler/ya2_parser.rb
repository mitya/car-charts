# Parses mods pages
# 
# Оценка безопасности не распарсена так как она не представлена в текстовом виде
# 
class YA2Parser
  SPACE_RE = %r{\s+}
  NON_ZERO_KEYS = [:consumption_city, :consumption_highway, :consumption_mixed, :gears, :ground_clearance, :bore, :luggage_min, :luggage_max].to_set

  def step_8_1__html_to_hashes_with_en_keys
    results = {}
    CW.parse_dir("07-mods-stripped") do |doc, basename, path|
      result = results[basename] = {}
      doc.css(".b-specifications__details .b-features__item_type_specs").each do |div|
        name = div.at_css(".b-features__name").text
        name_translation = Translations_Parameters[name.strip]
        value = div.at_css(".b-features__value").text.strip

        puts "TRANSLATION MISSING: #{name}" unless name_translation
        result[name_translation.to_s] = value
      end      
    end
    CW.write_data "08.1-mods", results
  end

  def step_8_2pre__check_mods
    raw_mods = CW.read_hash('08.1-mods', openstruct: false)
    raw_mods.each do |mod_key, properties|
      puts properties['safety_rating_name']
    end    
  end

  def step_8_2__parse_mod_values
    raw_mods = CW.read_hash('08.1-mods', openstruct: false)
    parsed_mods = {}

    raw_mods.first(1_000_000).each do |mod_key, properties|
      parsed = parsed_mods[mod_key] = {}
      
      properties.each do |key, string|
        case key.to_sym
        when :front_suspension, :rear_suspension, :front_brakes, :rear_brakes, :model_title, :body_title, :body_type, :price, :engine_title, :engine_spec, :category,
          :safety_rating_value, :safety_rating_name
        when :fuel_consumption
          values = string.split(%r{ / }).map { |str| CW.to_f(str) }
          parsed[:consumption_city], parsed[:consumption_highway], parsed[:consumption_mixed] = values
        when :bore_and_stroke
          values = string.split(/x|х/).map { |str| CW.to_f(str) }
          parsed[:bore], parsed[:stroke] = values
        when :max_power
          values = string.split(%r{ / }).map { |str| CW.to_i(str) }
          parsed[:max_power], parsed[:max_power_kw], parsed[:max_power_range_start], parsed[:max_power_range_end] = values
        when :max_torque
          values = string.split(%r{ / }).map { |str| CW.to_i(str) }
          parsed[:max_torque], parsed[:max_torque_range_start], parsed[:max_torque_range_end] = values
        when :tires
          parsed[:tires] = string.gsub(SPACE_RE, ' ')
        when :luggage_capacity
          values = string.split(SPACE_RE).map { |str| CW.to_i(str) }
          parsed[:luggage_min], parsed[:luggage_max] = values.first, values.last
        when :seats
          string = '4' if string == '2+2'
          values = string.split(SPACE_RE).map { |str| CW.to_i(str) }
          parsed[:seats_min], parsed[:seats_max] = values.first, values.last
        when :brand_country
          parsed[:brand_country] = Rus_CountryName_Codes[string]
        when :assembly_country
          names = string.split(%r{,\s+})
          names.map! { |rus_name| _Rus_CountryName_Codes(rus_name) }
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
        when  :eco_class
          parsed[key] = string          
        when :drive
          string = Translations_Values[:drive][string].to_s
          parsed[key] = string == '4WD' ? 'AWD' : string
        when :cylinder_placement, :injection, :engine_layout, :front_suspension, :rear_suspension,
             :front_brakes, :rear_brakes, :fuel, :fuel_rating, :compressor, :transmission
          translations = Translations_Values.fetch(key.to_sym)
          value = translations[string]          
          parsed[key] = value.is_a?(Symbol) ? value.to_s : value
        else
          parsed["__#{key}"] = string
        end
        
        # convert all keys to strings
        parsed.keys.each { |k| parsed[k.to_s] = parsed.delete(k) }
        
        # remove nil values because plists can't contain it
        parsed.delete_if { |k, v| v.nil? }

        # replace zeros with nils for some keys
        parsed.each { |k, v| parsed.delete(k) if v == 0 && NON_ZERO_KEYS.include?(k) }
        
        # # replace dashes with spaces in the key
        # new_key = upgrade_key(old_key)
        #
        # # store key parts as individual elements
        # brand_key, model_version, years, body, model_subkey, version_subkey, engine, power, transmission, drive = parse_new_key(new_key)
        # parsed[:body] = body
        # parsed[:model_key] = [brand_key, model_subkey].join('--')
        # parsed[:version_key] = version_subkey
        # parsed[:displacement_key] = engine[0..-2]        
      end
    end
    
    CW.write_data "08.2-mods", parsed_mods    

    # mods.first(mods_count).each do |old_key, mod|
    #

    #
    #   # create an array with the hash contents
    #   array = Keys_Used.each_with_index.map { |k, i| parsed[k] || '' }
    #
    #   parsed_mod_arrays[new_key] = array
    #   parsed_mod_hashes[new_key] = parsed
    # end
    #
    # KK.save_plist parsed_mod_arrays, "db-mods", OUTDIR
    # KK.save_plist parsed_mod_hashes, "db-mods-kv", OUTDIR
    # KK.save_data  parsed_mod_hashes, "db-mods-kv", OUTDIR
  end
end
