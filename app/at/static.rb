StaticData = {
  bodyNames: {
   "sedan"=>"sedan",
   "sedan_long"=>"sedan long",
   "wagon"=>"wagon",
   "hatch_3d"=>"hatch 3d",
   "hatch_5d"=>"hatch 5d",
   "suv"=>"SUV",
   "suv_2d"=>"SUV 2-dr",
   "suv_3d"=>"SUV 3-dr",
   "suv_4d"=>"SUV 4-dr",
   "suv_5d"=>"SUV 5-dr",
   "cabrio"=>"cabriolet",
   "coupe"=>"coupe",
   "coupe_2d"=>"coupe 2-dr",
   "coupe_5d"=>"coupe 5-dr",
   "crossover"=>"crossover",
   "crossover_3d"=>"crossover 3-dr",
   "crossover_5d"=>"crossover 5-dr",
   "minivan"=>"minivan",
   "minivan_3d"=>"minivan 3-dr",
   "minivan_5d"=>"minivan 5-dr",
   "van"=>"van",
   "pickup"=>"pickup",
   "pickup_2d"=>"pickup 2-dr",
   "pickup_4d"=>"pickup 4-dr",
  },
  premiumBrandKeys: %w(mercedes_benz audi bmw lexus infinity acura volvo cadillac range_rover),
  parameterGroups: [:engine, :dimensions, :other],
  parameterGroupsData: {
    engine: ["Engine", [:acceleration_0_100_kmh, :top_speed, :max_power, :max_power_kw, :max_torque, :engine_volume, :cylinder_count, :valves_per_cylinder, :compression, :bore, :gears, :consumption_city, :consumption_highway, :consumption_mixed]],
    dimensions: ["Dimensions", [:length, :width, :height, :ground_clearance, :wheelbase, :kerbweight, :gross_mass, :tires, :front_tire_rut, :rear_tire_rut, :luggage_min, :luggage_max, :tank_capacity, :doors, :seats]],
    other: ["Other", [:produced_since, :price]]
  },
  parameterNames: {
    top_speed: "Top Speed",
    acceleration_0_100_kmh: "Acelleration (0-100 km/h)",
    consumption_city: "Consumption (city)",
    consumption_highway: "Consumption (highway)",
    consumption_mixed: "Consumption (mixed)",
    engine_volume: "Displacement",
    cylinder_count: "Cylider Count",
    valves_per_cylinder: "Valves per Cylider",
    compression: "Compression",
    bore: "Bore",
    max_power: "Power (hp)",
    max_power_kw: "Power (kW)",
    max_torque: "Torque",
    # max_power_range_start: :value,
    # max_torque_range_start: :value,
    gears: "Gears Number",
    length: "Length",
    width: "Width",
    height: "Height",
    ground_clearance: "Ground Clearance",
    tires: "Tires",
    front_tire_rut: "Front Tire Rut",
    rear_tire_rut: "Rear Tire Rut",
    wheelbase: "Wheelbase",
    luggage_min: "Luggage (min)",
    luggage_max: "Luggage (max)",
    tank_capacity: "Tank Capacity",
    kerbweight: "Kerb Weight",
    gross_mass: "Gross Weight",
    doors: "Doors Count",
    seats: "Seats Count",
    produced_since: "Produced Since",
    price: "Price",
  },
  parameterUnits: {
    top_speed: :kmh,
    acceleration_0_100_kmh: :s,
    consumption_city: :l100km,
    consumption_highway: :l100km,
    consumption_mixed: :l100km,
    engine_volume: :cc,
    cylinder_count: :count,
    valves_per_cylinder: :count,
    compression: :value,
    bore: :mm,
    max_power: :hp,
    max_power_kw: :kw,
    max_power_range_start: :value,
    max_torque: :nm,
    max_torque_range_start: :value,
    gears: :count,
    length: :mm,
    width: :mm,
    height: :mm,
    ground_clearance: :mm,
    tires: :tires,
    front_tire_rut: :mm,
    rear_tire_rut: :mm,
    wheelbase: :mm,
    luggage_min: :l,
    luggage_max: :l,
    tank_capacity: :l,
    gross_mass: :kg,
    kerbweight: :kg,
    doors: :count,
    seats: :count,
    produced_since: :date,
    price: :rouble,
  },
  parameterUnitNames: {
    kmh: "km/h",
    s: "s",
    l100km: "L/100 km",
    cc: "cc",
    count: "",
    value: "",
    mm: "mm",
    hp: "hp",
    kw: "kW",
    nm: "Nm",
    tires: "",
    l: "l",
    kg: "kg",
    date: "",
    rouble: "",  
  },
  categoryNames: {
     A: ["City (A class)", "City"],
     B: ["Supermini (B class)", "Supermini"],
     C: ["Compact (C/Golf class)", "Compacts"],
     D: ["Family (D class)", "Family"],
     E: ["Business (E class)", "Business"],
     F: ["Premium Sedans", "Premium"],
    Xb: ["Very Compact SUVs"],
    Xc: ["Compact SUVs"],
    Xd: ["Compact+ SUVs"],
    Xe: ["Mid-Size SUVs"],
    Xf: ["Full-Size SUVs"],
    Xx: ["Offroad SUVs"],
    Wx: ["AWD Wagons"],
    Sr: ["Roadsters"],
    Sc: ["Sportcars"],
    Mb: ["Mini MPVs"],
    Mc: ["Compact MPVs"],
    Me: ["Mid-Size MPVs"],
    Pc: ["Compact Pickups"],
    Pd: ["Full-Size Pickups"],  
  },
  brandNames: {
		acura: "Acura",
		alfa_romeo: "Alfa Romeo",
		audi: "Audi",
		bmw: "BMW",
		cadillac: "Cadillac",
		chery: "Chery",
		chevrolet: "Chevrolet",
		chrysler: "Chrysler",
		citroen: "Citroen",
		daewoo: "Daewoo",
		dodge: "Dodge",
		fiat: "FIAT",
		ford: "Ford",
		gaz: "GAZ",
		great_wall: "Great Wall",
		honda: "Honda",
		hummer: "Hummer",
		hyundai: "Hyundai",
		infiniti: "Infiniti",
		jaguar: "Jaguar",
		jeep: "Jeep",
		kia: "Kia",
		land_rover: "Land Rover",
		lexus: "Lexus",
		mazda: "Mazda",
		mercedes_benz: "Mercedes-Benz",
		mini: "MINI",
		mitsubishi: "Mitsubishi",
		nissan: "Nissan",
		opel: "Opel",
		peugeot: "Peugeot",
		porsche: "Porsche",
		renault: "Renault",
		saab: "Saab",
		seat: "SEAT",
		skoda: "Skoda",
		ssangyong: "SsangYong",
		subaru: "Subaru",
		suzuki: "Suzuki",
		toyota: "Toyota",
		uaz: "UAZ",
		vaz: "VAZ (LADA)",
		volkswagen: "Volkswagen",
		volvo: "Volvo",
	},  
  chartColors: {
    top_speed:              [  0, 75, 50],
    acceleration_0_100_kmh: [ 30, 75, 50],
    consumption_city:       [ 60, 75, 50],
    consumption_highway:    [ 90, 75, 50], 
    consumption_mixed:      [120, 75, 50],
    engine_volume:          [150, 75, 50],
    cylinder_count:         [180, 75, 50],
    valves_per_cylinder:    [210, 75, 50],
    compression:            [240, 75, 50],
    bore:                   [270, 75, 50],
    max_power:              [300, 75, 50],
    max_power_kw:           [330, 75, 50],
    max_torque:             [360, 75, 50],
    gears:                  [  0, 50, 50],
    length:                 [ 30, 50, 50],
    width:                  [ 60, 50, 50],
    height:                 [ 90, 50, 50],
    ground_clearance:       [120, 50, 50],
    tires:                  [150, 50, 50],
    front_tire_rut:         [180, 50, 50],
    rear_tire_rut:          [210, 50, 50],
    wheelbase:              [240, 50, 50],
    luggage_min:            [270, 50, 50],
    luggage_max:            [300, 50, 50],
    tank_capacity:          [330, 50, 50],
    gross_mass:             [360, 50, 50],
    kerbweight:             [  0, 50, 50],
    doors:                  [ 30, 50, 50],
    seats:                  [ 60, 50, 50],
    produced_since:         [ 90, 50, 50],
    price:                  [120, 50, 50],
  },
  colors: [
    [  0, 75, 70],
    [240, 75, 70],
    [120, 75, 70],
    [ 30, 75, 70],
    [270, 75, 70],
    [ 60, 75, 70],
    [210, 75, 70],
    [300, 75, 70],
    [ 90, 75, 70],    
    [330, 50, 50],
    [ 60, 50, 50],
    [240, 50, 50],
    [ 90, 50, 50],
  ]
}
