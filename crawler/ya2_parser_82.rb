class YA2Parser
  # parse mod values
  def step_82
    models = read_objects(F13)
    models_index = models.index_by(&:key)
    raw_mods = read_hash(F81, openstruct: false)
    parsed_mods = {}

    raw_mods.first(1_000_000).each do |mod_key, properties|
      parsed = Mash.new

      properties.each do |key, string|
        case key.to_sym
        when :front_suspension, :rear_suspension, :front_brakes, :rear_brakes, :model_title, :body_title, :body_type, :price, :engine_title, :engine_spec, :category
        when :safety_rating_value, :safety_rating_name
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
        when :cylinder_placement, :engine_layout, :fuel, :fuel_rating, :transmission, :drive, :compressor, :injection,
              :front_suspension, :rear_suspension, :front_brakes, :rear_brakes
          parsed[key] = TranslationHelper.instance.translate_value(key, string)
        when :eco_class
          parsed[key] = string
        else
          parsed["__#{key}"] = string
        end
      end

      # replace dashes with spaces in the key
      new_key = ModKey.from_space_key(mod_key)

      # store key parts as individual elements
      parsed.body = new_key.body
      parsed.body_base = new_key.body_base
      parsed.body_version = new_key.body_version
      parsed.model_key = new_key.brand_and_model
      parsed.version_key = new_key.version
      parsed.generation_key = new_key.brand_and_model_and_year
      parsed.year = CW.to_i(new_key.years, zero: false)
      parsed.displacement_key = new_key.displacement || CW.make_displacement_key(parsed.displacement)

      if parsed.body_version
        parsed.body_version = models_index[new_key.space_generation_body_key].bodytype_version.to_s # replace swb_x = SWB X
      end

      if new_key.aggregate == nil
        new_key.aggregate = CW.aggregate_key(parsed.displacement_key, parsed.fuel, parsed.max_power, parsed.transmission, parsed.drive)
      end      

      # convert all keys to strings
      # parsed.keys.reject { |k| k.is_a?(String) }.each { |k| parsed[k.to_s] = parsed.delete(k) }

      # remove nil values because plists can't contain it
      parsed.delete_if { |k, v| v.nil? }

      # replace zeros with nils for some keys
      parsed.each { |k, v| parsed.delete(k) if v == 0 && NON_ZERO_KEYS.include?(k) }

      parsed_mods[new_key.to_s_with_spaces] = parsed.hash
    end

    parsed_mods_arrays = {}
    parsed_mods.each do |mod_key, mod_hash|
      parsed_mods_arrays[mod_key] = CWD.used_fields.each_with_index.map { |k, i| mod_hash[k] || '' }
    end

    write_data_to_plist F82, parsed_mods_arrays  
    write_data_to_binary F82, parsed_mods
    write_data F82, parsed_mods
    
    # write_data_to_plist "debug-#{F82}", parsed_mods.first(20).to_h
    # write_data "debug-#{F82}.keys", parsed_mods.keys.sort
  end  
end
