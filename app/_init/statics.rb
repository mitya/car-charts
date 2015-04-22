Statics = {
  # chartColors: {
  #   top_speed:              [  0, 75, 50],
  #   acceleration_100kmh:    [ 30, 75, 50],
  #   consumption_city:       [ 60, 75, 50],
  #   consumption_highway:    [ 90, 75, 50],
  #   consumption_mixed:      [120, 75, 50],
  #   displacement:           [150, 75, 50],
  #   cylinder_count:         [180, 75, 50],
  #   cylinder_valves:        [210, 75, 50],
  #   compression:            [240, 75, 50],
  #   bore:                   [270, 75, 50],
  #   max_power:              [300, 75, 50],
  #   max_power_kw:           [330, 75, 50],
  #   max_torque:             [360, 75, 50],
  #   gears:                  [  0, 50, 50],
  #   length:                 [ 30, 50, 50],
  #   width:                  [ 60, 50, 50],
  #   height:                 [ 90, 50, 50],
  #   ground_clearance:       [120, 50, 50],
  #   tires:                  [150, 50, 50],
  #   front_tire_rut:         [180, 50, 50],
  #   rear_tire_rut:          [210, 50, 50],
  #   wheelbase:              [240, 50, 50],
  #   luggage_min:            [270, 50, 50],
  #   luggage_max:            [300, 50, 50],
  #   tank_capacity:          [330, 50, 50],
  #   gross_mass:             [360, 50, 50],
  #   kerbweight:             [  0, 50, 50],
  #   doors:                  [ 30, 50, 50],
  #   seats_min:              [ 60, 50, 50],
  #   seats_max:              [ 90, 50, 50],
  #   produced_since:         [120, 50, 50],
  #   price:                  [140, 50, 50],
  # },
  colors: [
    [135, 70, 65, 135, 99, 55], # green
    [ 30, 79, 93,  22, 83, 87], # orange
    [300, 55, 75, 300, 85, 65], # violet
    [ 50, 71, 98,  45, 90, 90], # yellow
    [ 10, 84, 98,   5, 88, 79], # red
    [225, 75, 90, 225, 95, 75], # blue
    [  0,  0, 60,   0,  0, 40], # gray
    [  0,  0, 20,   0,  0,  0], # black
 ] 
}


Samples = {}

Samples[:business] = [
  "audi a6 2014 sedan 3.0d-218ps-AMT-FWD",
  "audi a6 2014 sedan 3.0i-333ps-AMT-AWD",
  "bmw 5er 2013 sedan 3.0d-258ps-AT-RWD",
  "bmw 5er 2013 sedan 3.0i-306ps-AT-AWD",
  "bmw 5er 2013 sedan 3.0i-306ps-AT-RWD",
  "bmw 5er 2013 sedan 4.4i-449ps-AT-RWD",
  "lexus gs 2011 sedan 3.5h-292ps-CVT-RWD",
  "mercedes e_klasse 2013 sedan 3.0i-333ps-AT-RWD",
  "mercedes e_klasse 2013 sedan 3.5i-252ps-AT-RWD",
  "mercedes e_klasse 2013 sedan 3.5i-333ps-AT-RWD",
  "mercedes e_klasse 2013 sedan 4.7i-408ps-AT-RWD"  
]

Samples[:compact] = [
  "ford focus 2014 hatch_5d 1.6i-125ps-AMT-FWD",
  "ford focus 2014 hatch_5d 2.0d-150ps-AMT-FWD",
  "honda civic 2013 hatch_5d 1.8i-142ps-AT-FWD",
  "opel astra 2012 hatch_5d 1.6i-180ps-AT-FWD",
  "opel astra 2012 hatch_5d 2.0d-160ps-AT-FWD",
  "skoda octavia 2013 hatch_5d 1.8i-180ps-AMT-FWD",
  "skoda octavia 2013 hatch_5d 2.0d-143ps-AMT-FWD",
  "volkswagen golf 2013 hatch_5d 1.6d-110ps-AMT-FWD",
  "volkswagen golf 2013 hatch_5d 2.0d-150ps-AMT-FWD",
  "volvo c30 2010 hatch_3d 2.0i-145ps-AMT-FWD",
  "volvo c30 2010 hatch_3d 2.4d-180ps-AT-FWD",
]

Samples[:family] = [
  "audi a4 2011 sedan 2.0i-180ps-CVT-FWD", 
  "audi a4 2011 sedan 2.0i-211ps-AMT-AWD",
  "bmw 3er 2012 sedan 1.6i-170ps-AT-RWD",
  "bmw 3er 2012 sedan 2.0i-184ps-AT-RWD",
  "bmw 3er 2012 sedan 2.0i-245ps-AT-RWD",
  "ford mondeo 2015 sedan 2.0i-199ps-AT-FWD",
  "honda accord 2014 sedan 2.0i-150ps-CVT-FWD",
  "honda accord 2014 sedan 2.4i-180ps-AT-FWD", 
  "hyundai i40 2012 sedan 2.0i-178ps-AT-FWD",
  "mazda 6 2015 sedan 2.0i-150ps-AT-FWD",
  "mazda 6 2015 sedan 2.5i-192ps-AT-FWD",
  "mercedes c_klasse 2014 sedan 2.0i-184ps-AT-RWD", 
  "mercedes c_klasse 2014 sedan 2.0i-211ps-AT-RWD",
  "skoda superb 2015 hatch_5d 1.8i-180ps-AMT-FWD",
  "toyota camry 2014 sedan 2.0i-149ps-AT-FWD", 
  "toyota camry 2014 sedan 2.5i-181ps-AT-FWD", 
  "volkswagen passat 2011 sedan 1.8i-152ps-AMT-FWD",
  "volkswagen passat 2011 sedan 2.0i-210ps-AMT-FWD",
  "volkswagen passat 2015 sedan 2.0d-150ps-AMT-FWD"
]

# more D-class stuff
Samples[:family] = ["acura tlx 2014 sedan 3.5i-290ps-AT-AWD", "bmw 3er 2012 sedan 2.0i-184ps-AT-RWD", "bmw 3er 2012 sedan 2.0i-245ps-AT-RWD", "bmw 3er 2012 sedan 3.0i-306ps-AT-RWD", "cadillac bls 2006 sedan 1.9d-150ps-AT-FWD", "ford mondeo 2015 sedan 2.0i-199ps-AT-FWD", "honda accord 2014 sedan 2.0i-150ps-CVT-FWD", "honda accord 2014 sedan 2.4i-180ps-AT-FWD", "hyundai i40 2012 sedan 2.0i-178ps-AT-FWD", "infiniti q50 2013 sedan 3.5h-354ps-AT-RWD", "jaguar xe 2014 sedan 2.0i-200ps-AT-RWD", "lexus is 2013 sedan 2.5h-181ps-CVT-RWD", "mercedes c_klasse 2014 sedan 2.0i-184ps-AT-RWD", "mercedes c_klasse 2014 sedan 2.0i-211ps-AT-RWD", "nissan teana 2014 sedan 2.5i-172ps-CVT-FWD", "opel insignia 2013 sedan 1.6i-170ps-AT-FWD", "skoda superb 2015 hatch_5d 1.8i-180ps-AMT-FWD", "toyota avensis 2015 sedan 1.8i-147ps-CVT-FWD", "toyota camry 2014 sedan 2.0i-149ps-AT-FWD", "toyota camry 2014 sedan 2.5i-181ps-AT-FWD", "volkswagen passat 2011 sedan 1.8i-152ps-AMT-FWD", "volkswagen passat 2011 sedan 2.0i-210ps-AMT-FWD", "volkswagen passat 2015 sedan 2.0d-150ps-AMT-FWD", "volkswagen passat_cc 2011 sedan 1.8i-152ps-AMT-FWD", "volvo s60 2013 sedan 2.0i-180ps-AT-FWD"]

Samples[:favorites] = [
  "audi--a4--2011", 
  "bmw--3er--2012", 
  "ford--mondeo--2015", 
  "honda--accord--2014", 
  "hyundai--i40--2012", 
  "mazda--6--2015", 
  "mercedes--c_klasse--2014", 
  "skoda--superb--2015", 
  "toyota--camry--2014", 
  "volkswagen--passat--2011",
  "volkswagen--passat--2015"
]
