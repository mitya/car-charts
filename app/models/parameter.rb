class Parameter
  attr_accessor :key, :name

  def initialize(key, name)
    @key, @name = key.to_sym, name
  end

  def unitKey
    Metadata.parameterUnits[key]
  end
  
  def unitName
    Metadata.parameterUnitNames[unitKey]
  end  
  
  def long?
    LongParameters.containsObject(key)
  end
  
  def appliesToBody?
    BodyParameters.containsObject(key)
  end
  
  def selected?
    Disk.currentParameters.include?(self)
  end
  
  def select!
    Disk.currentParameters = Disk.currentParameters.dupWithToggledObject(self)
  end
  
  def formattedValue(value)
    text = case 
      when key == :produced_since || key == :produced_till
        year, month = value.to_i.divmod(100)
        month == 0 ? year : "#{year}.#{month.to_s.rjust(2, '0')}"
      when Float === value
        "%.1f" % value
      else 
        value
    end
    "#{text} #{unitName}".strip
  end
  
  class << self
    attr_reader :all

    def parameterForKey(key)
      @index[key]
    end
    
    def load
      @all = Metadata.parameterNames.map { |key, name| new(key, name) }
      @index = @all.uniqueIndexBy(&:key)
    end
    
    def groupKeys
      Metadata[:parameterGroups]
    end
    
    def nameForGroup(groupKey)
      Metadata[:parameterGroupsData][groupKey][0]
    end
    
    def parametersForGroup(groupKey)
      Metadata[:parameterGroupsData][groupKey][1].map { |k| parameterForKey(k) }
    end
  end
  
  BodyParameters = NSSet.setWithArray([:length, :width, :height])
  LongParameters = NSSet.setWithArray([:consumption_city, :consumption_highway, :consumption_mixed])
end

# "skoda fabia 2010 hatch_5d 1.6i-105ps-AT-FWD": {
#   "top_speed": 185,
#   "acceleration_100kmh": 11.5,
#   "consumption_city": 10.2,
#   "consumption_highway": 6.1,
#   "consumption_mixed": 7.6,
#   "displacement": 1598,
#   "fuel": "petrol",
#   "fuel_rating": "A95",
#   "cylinder_count": 4,
#   "cylinder_placement": "inline",
#   "injection": "distributed_injection",
#   "engine_layout": "front_transversely",
#   "cylinder_valves": 4,
#   "compression": 10.5,
#   "bore": 76.5,
#   "max_power": 105,
#   "max_power_kw": 77,
#   "max_power_range_start": 5600,
#   "max_torque": 153,
#   "max_torque_range_start": 3800,
#   "transmission": "AT",
#   "gears": 6,
#   "drive_config": "FWD",
#   "length": 4000,
#   "width": 1642,
#   "height": 1498,
#   "ground_clearance": 149,
#   "tires": "185/60/R14,195/55/R15",
#   "front_tire_rut": 1433,
#   "rear_tire_rut": 1426,
#   "wheelbase": 2451,
#   "luggage_min": 315,
#   "luggage_max": 1180,
#   "tank_capacity": 45,
#   "gross_mass": 1650,
#   "kerbweight": 1135,
#   "front_suspension": "independent_coil",
#   "rear_suspension": "semidependent_coil",
#   "front_brakes": "disc_ventilated",
#   "rear_brakes": "drum",
#   "countries": "Чехия Россия",
#   "body_type": "хэтчбек",
#   "car_class": "В",
#   "doors": "5",
#   "seats": "5",
#   "produced_since": "Июнь 2010",
#   "model_title": "Skoda Fabia",
#   "body_title": "хэтчбек 5 дв",
#   "engine_title": "Ambition",
#   "engine_spec": "1.6 AT (105 л.с.)",
#   "price": "549 000 руб."
# },
