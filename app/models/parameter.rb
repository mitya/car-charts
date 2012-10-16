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
  
  class << self
    attr_reader :all

    def parameterForKey(key)
      @index[key]
    end
    
    def load
      @all = Metadata.parameterNames.map { |key, name| new(key, name) }
      @index = @all.uniqueIndexBy(&:key)
    end
  end
  
  BodyParameters = NSSet.setWithArray([:length, :width, :height])
end

# "skoda fabia 2010 hatch_5d 1.6i-105ps-AT-FWD": {
#   "top_speed": 185,
#   "acceleration_0_100_kmh": 11.5,
#   "consumption_city": 10.2,
#   "consumption_highway": 6.1,
#   "consumption_mixed": 7.6,
#   "engine_volume": 1598,
#   "fuel": "petrol",
#   "fuel_rating": "A95",
#   "cylinder_count": 4,
#   "cylinder_placement": "inline",
#   "injection": "distributed_injection",
#   "engine_placement": "front_transversely",
#   "valves_per_cylinder": 4,
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
