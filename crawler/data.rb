# encoding: utf-8

# loader & source parcer constants

BASE_BODY_TYPES= {
  "седан"       => "sedan",
  "универсал"   => "wagon",
  "хэтчбек"     => "hatch",
  "купе"        => "coupe",
  "кабриолет"   => "cabrio",
  "кроссовер"   => "crossover",
  "вседорожник" => "SUV",
  "минивэн"     => "minivan",
  "пикап"       => "pickup",
  "фургон"      => "van"
}

BASE_BODY_TYPES_RE = Regexp.new(BASE_BODY_TYPES.keys.join('|'))

BODY_TYPES = {
  "пикап"            => "pickup",
  "фургон"           => "van",
  "вседорожник 3 дв" => "suv_3d",
  "вседорожник 5 дв" => "suv_5d",
  "кабриолет"        => "cabrio",
  "кроссовер"        => "crossover",
  "купе"             => "coupe",
  "хэтчбек 3 дв"     => "hatch_3d",
  "минивэн"          => "minivan",
  "универсал"        => "wagon",
  "вседорожник"      => "suv",
  "хэтчбек 5 дв"     => "hatch_5d",
  "седан"            => "sedan"

}
  
VENDORS_TRANSLIT = {
  "LADA (ВАЗ)"    => "VAZ",
  "УАЗ"           => "UAZ",
  "ГАЗ"           => "GAZ",
  "Mercedes-Benz" => "Mercedes"
}

MODEL_ENGLISH_TITLE_FIXES = {
  "Audi A6 Allroad quattro"    => "A6 allroad quattro",
  "BMW 1 серия М"              => "1 M",
  "LADA (ВАЗ) Надежда"         => "Nadezhda",
  "LADA (ВАЗ) Нива 4х4 (2121)" => "2121 Niva",
  "LADA (ВАЗ) Нива 4х4 (2131)" => "2131 Niva",
  "LADA (ВАЗ) Ока"             => "Oka",
  "ГАЗ 31105 Волга"            => "31105 Volga",
  "Chrysler 300С"              => "300C",
  "Chrysler 300М"              => "300M",  
}

# common constants

Keys_All = %w(body version_key transmission drive engine_vol fuel power model_key
  valves_per_cylinder consumption_city max_power_kw cylinder_placement compression gross_mass bore doors compressor
  injection tires max_torque_range_start rear_brakes max_torque max_power stroke seats_min seats_max acceleration_0_100_kmh consumption_highway
  engine_spec consumption_mixed countries fuel_rating height drive_config produced_since rear_tire_rut engine_title luggage_min
  length engine_volume body_type max_power_range_start kerbweight category ground_clearance luggage_max front_suspension
  price tank_capacity wheelbase model_title front_brakes engine_placement rear_suspension top_speed gears width front_tire_rut
  cylinder_count body_title produced_till max_torque_range_end max_power_range_end version base_model_key fixed_model_name)
Keys_Rejected = %w(front_suspension rear_suspension front_brakes rear_brakes model_title body_title body_type price engine_title engine_spec category)
Keys_Used = Keys_All - Keys_Rejected

Translations_Vendors = {
  "Acura"         => "acura",
  "Alfa Romeo"    => "alfa_romeo",
  "Audi"          => "audi",
  "BMW"           => "bmw",
  "Cadillac"      => "cadillac",
  "Chery"         => "chery",
  "Chevrolet"     => "chevrolet",
  "Chrysler"      => "chrysler",
  "Citroen"       => "citroen",
  "Daewoo"        => "daewoo",
  "Dodge"         => "dodge",
  "FIAT"          => "fiat",
  "Ford"          => "ford",
  "Great Wall"    => "great_wall",
  "Honda"         => "honda",
  "Hummer"        => "hummer",
  "Hyundai"       => "hyundai",
  "Infiniti"      => "infiniti",
  "Jaguar"        => "jaguar",
  "Jeep"          => "jeep",
  "Kia"           => "kia",
  "Land Rover"    => "land_rover",
  "Lexus"         => "lexus",
  "MINI"          => "mini",
  "Mazda"         => "mazda",
  "Mercedes-Benz" => "mercedes_benz",
  "Mitsubishi"    => "mitsubishi",
  "Nissan"        => "nissan",
  "Opel"          => "opel",
  "Peugeot"       => "peugeot",
  "Porsche"       => "porsche",
  "Renault"       => "renault",
  "SEAT"          => "seat",
  "Saab"          => "saab",
  "Skoda"         => "skoda",
  "SsangYong"     => "ssangyong",
  "Subaru"        => "subaru",
  "Suzuki"        => "suzuki",
  "Toyota"        => "toyota",
  "Volkswagen"    => "volkswagen",
  "Volvo"         => "volvo",
  "LADA (ВАЗ)"    => "vaz",
  "ВАЗ"           => "vaz",
  "ВАЗ (LADA)"    => "vaz",
  "ГАЗ"           => "gaz",
  "УАЗ"           => "uaz"
}

Translations_Parameters = {
 "Максимальная скорость, км/ч"                    => :top_speed,
 "Разгон до 100 км/ч, с"                          => :acceleration_0_100_kmh,
 "Расход топлива (город / трасса / смешанный), л" => :fuel_consumption,
 "Объем двигателя, см3"                           => :engine_volume,
 "Тип двигателя"                                  => :fuel,
 "Марка топлива"                                  => :fuel_rating,
 "Количество цилиндров"                           => :cylinder_count,
 "Расположение цилиндров"                         => :cylinder_placement,
 "Число клапанов на цилиндр"                      => :valves_per_cylinder,
 "Система питания двигателя"                      => :injection,
 "Расположение двигателя"                         => :engine_placement,
 "Степень сжатия"                                 => :compression,
 "Тип наддува"                                    => :compressor,
 "Диаметр цилиндра и ход поршня, мм"              => :bore_and_stroke,
 "Максимальная мощность, л.с./кВт при об/мин"     => :max_power,
 "Максимальный крутящий момент, Н*м при об/мин"   => :max_torque,
 "Тип трансмиссии"                                => :transmission,
 "Количество передач"                             => :gears,
 "Тип привода"                                    => :drive,
                                                     
 "Длина, мм"                   => :length,
 "Ширина, мм"                  => :width,
 "Высота, мм"                  => :height,
 "Клиренс, мм"                 => :ground_clearance,
 "Размер колес"                => :tires,
 "Ширина передней колеи, мм"   => :front_tire_rut,
 "Ширина задней колеи, мм"     => :rear_tire_rut,
 "Колесная база, мм"           => :wheelbase,
 "Объем багажника мин/макс, л" => :luggage_capacity,
 "Объем топливного бака, л"    => :tank_capacity,
 "Полная масса, кг"            => :gross_mass,
 "Снаряженная масса, кг"       => :kerbweight,
                                  
 "Тип передней подвески"       => :front_suspension,
 "Тип задней подвески"         => :rear_suspension,
 "Передние тормоза"            => :front_brakes,
 "Задние тормоза"              => :rear_brakes,
                               
 "Страна выпуска"              => :countries,
 "Тип кузова"                  => :body_type,
 "Количество дверей"           => :doors,
 "Количество мест"             => :seats,
 "Начало производства"         => :produced_since, 
 "Окончание производства"      => :produced_till, 
 "Класс автомобиля"            => :category,

}

Translations_Values_Suspensions = {
  "зависимая, пневмоэлемент"        => :dependent_pneumo,
  "зависимая, пружинная"            => :dependent_coil,
  "зависимая, рессорная"            => :dependent_spring,
  "полунезависимая, торсионная"     => :semidependent_torsion,
  "полунезависимая, пружинная"      => :semidependent_coil,
  "независимая, рессорная"          => :independent_spring,
  "независимая, гидропневмоэлемент" => :independent_hydro_pneumo,
  "независимая, торсионная"         => :independent_torsion,
  "независимая, пневмоэлемент"      => :independent_pneumo,
  "независимая, пружинная"          => :independent_coil
}

Translations_Values_Brakes = {
 "керамические вентилируемые" => :ceramic_ventilated,
 "дисковые барабанные"        => :disc_or_drum,
 "барабанные  дисковые"       => :disc_or_drum,
 "барабанные"                 => :drum,
 "дисковые вентилируемые"     => :disc_ventilated,
 "дисковые"                   => :disc
}

Translations_Values_Drives = { "полный" => "4WD", "передний" => "FWD", "задний" => "RWD" }

Translations_Values_FuelSigns = { "бензин" => "i", "дизель" => "d" }

Translations_Values = {
 "cylinder_placement" => { 
   "W-образное"                                 => :W, 
   "роторный двигатель"                         => :ROT,   # rotary 
   "V-образное с малым углом развала цилиндров" => :V, 
   "оппозитное"                                 => :FLT,   # flat
   "V-образное"                                 => :V, 
   "рядное"                                     => :INL    # inline
 },
 "injection"=> {
   "центральный впрыск"                                                             => :CI,  # central_injection
   "двигатель с разделенными камерами сгорания (вихрекамерный или предкамерный)"    => :SC,  # separated_combustor
   "карбюратор"                                                                     => :CR,  # carburetor
   "двигатель с неразделенными камерами сгорания (непосредственный впрыск топлива)" => :NSC, # nonseparated_combustor
   "непосредственный впрыск в камеру сгорания"                                      => :DI,  # direct_injection
   "распределенный впрыск"                                                          => :DSI  # distributed_injection
 }, 
 "engine_placement" => { 
   "центральное"          => :MD,   # mid
   "заднее"               => :RR,   # rear
   "переднее, продольное" => :FRLN, # front longitudinally 
   "переднее, поперечное" => :FRTR  # front transversely
 },
 "compressor" => { 
   "объемный нагнетатель с механическим приводом"    => :SC,  # supercharger
   "турбонаддув"                                     => :TR, 
   "турбонаддув с промежуточным охлаждением воздуха" => :TRI, # turbo intercooler
   "нет"                                             => nil 
 },
 "front_suspension" => Translations_Values_Suspensions,
 "rear_suspension"  => Translations_Values_Suspensions,
 "front_brakes"     => Translations_Values_Brakes,
 "rear_brakes"      => Translations_Values_Brakes,
 "drive"            => {"задний" => :RWD, "полный" => :AWD, "передний" => :FWD},
 "fuel"             => {"гибрид" => :H, "дизель" => :D, "бензин" => :P},
 "fuel_rating"      => {"АИ-76" => :A76, "АИ-92" => :A92, "АИ-98" => :A98, "ДТ" => :DT, "АИ-95" => :A95},
 "transmission"     => {"вариатор" => :CVT, "роботизированная" => :AMT, "автомат" => :AT, "механическая" => :MT}
}

Reductions_Body_Body = {
  "audi--hatch_5d_sportback"  => "hatch_5d",           
  "audi--coupe_5d_sportback"  => "coupe_5d",
  "audi--suv_v12_tdi"         => "suv",                  
  "kia--coupe_koup"           => "coupe",                   
  "land_rover--suv_3d_90"     => "suv_3d",                    
  "land_rover--suv_4d"        => "suv_4d",                       
  "land_rover--suv_5d_110"    => "suv_5d",        
  "lexus--cabrio_is_250c"     => "cabrio",                            
  "opel--wagon_sports_tourer" => "wagon",          
  "peugeot--cabrio_cc"        => "cabrio",                    
  "peugeot--wagon_sw"         => "wagon",
  "peugeot--partner--minivan_5d_partner_tepee"   => "minivan_5d",       
  "vaz--wagon_2104"           => "wagon",                   
  "vaz--hatch_5d_sport"       => "hatch_5d",               
  "vaz--hatch_3d_coupe"       => "hatch_3d",        
  "volkswagen--hatch_3d_gti"  => "hatch_3d",                 
  "volkswagen--hatch_5d_gti"  => "hatch_5d",         
}

Reductions_Body_Model = {
  "lexus--sedan_is_f"             => "sedan IS-F",
  "mitsubishi--hatch_5d_ralliart" => "hatch_5d Lancer Ralliart",
  "mitsubishi--sedan_ralliart"    => "sedan Lancer Ralliart",
  "renault--crossover_stepway"    => "hatch_5d Sandero Stepway",
  "nissan--crossover_plus_2"      => "crossover Qashqai +2",
  "opel--hatch_3d_gtc"            => "hatch_3d Astra GTC",
}

Reductions_Body_Version = {
  "audi--r8--cabrio_gt_spyder"                  => "cabrio GT Spyder",             
  "audi--r8--coupe_gt"                          => "coupe GT",                     
  "chevrolet--captiva--crossover_5_seats"       => "crossover 5 seats",
  "chevrolet--captiva--crossover_7_seats"       => "crossover 7 seats",            
  "dodge--challenger--coupe_srt8"               => "coupe SRT8",                   
  "dodge--ram--pickup_2d_1500_regular_cab"      => "pickup 2-dr 1500 regular cab",   
  "dodge--ram--pickup_2d_1500_regular_cab_long" => "pickup 2-dr 1500 regular cab long",
  "dodge--ram--pickup_4d_1500"                  => "pickup 4-dr 1500",               
  "fiat--500--hatch_3d_abarth"                  => "hatch_3d Abarth",              
  "ford--ranger--pickup_double_cab"             => "pickup Double Cab",            
  "ford--ranger--pickup_extended_cab"           => "pickup Extended Cab",          
  "ford--torneo_connect--minivan_kombi_lwb"     => "minivan LWB",
  "ford--torneo_connect--minivan_kombi_swb"     => "minivan SWB",            
  "ford--transit--minivan_kombi"                => "minivan Kombi",                
  "ford--transit--van_swb_h1_van"               => "van SWB H1",               
  "ford--transit--van_swb_h2_van"               => "van SWB H2",               
  "great_wall--deer--suv_2d_g1"                 => "suv_2d G1",                    
  "great_wall--deer--suv_2d_g2"                 => "suv_2d G2",                    
  "great_wall--deer--suv_4d_g3"                 => "suv_4d G3",                    
  "great_wall--deer--suv_4d_g3_awd"             => "suv_4d G3 AWD",                
  "great_wall--deer--suv_4d_g5"                 => "suv_4d G5",                    
  "great_wall--deer--suv_4d_g5_awd"             => "suv_4d G5 AWD",      
  "jaguar--xf--sedan_xfr"                       => "sedan XFR",                    
  "jaguar--xk--cabrio_r"                        => "cabrio R",                     
  "jaguar--xk--coupe_r"                         => "coupe R",                      
  "mercedes_benz--cl--coupe_amg"                => "coupe AMG",                    
  "mercedes_benz--clk--cabrio_amg"              => "cabrio AMG",                   
  "mercedes_benz--clk--coupe_amg"               => "coupe AMG",                    
  "mercedes_benz--e--sedan_amg"                 => "sedan AMG",                    
  "mercedes_benz--g--suv_5d_amg"                => "suv_5d AMG",                   
  "mercedes_benz--m--suv_amg"                   => "suv AMG",                      
  "mercedes_benz--s--sedan_amg"                 => "sedan AMG",                    
  "mercedes_benz--s--sedan_amg_long"            => "sedan_long AMG",               
  "mercedes_benz--sl--cabrio_amg"               => "cabrio AMG",                   
  "mercedes_benz--slk--cabrio_amg"              => "cabrio AMG",                  
  "mini--clubman--wagon_cooper_s"               => "wagon Cooper S",               
  "mini--clubman--wagon_jcw"                    => "wagon JCW",                    
  "mini--cooper--cabrio_sidewalk"               => "cabrio Sidewalk",              
  "mini--cooper--hatch_3d_cooper_s"             => "hatch_3d Cooper S",            
  "mini--cooper--hatch_3d_jcw"                  => "hatch_3d JCW",                 
  "mini--countryman--crossover_cooper"          => "crossover Cooper",             
  "mini--countryman--crossover_cooper_s"        => "crossover Cooper S",           
  "renault--modus--minivan_grand"               => "minivan Grand",                
  "skoda--fabia--hatch_5d_monte_carlo"          => "hatch_5d Monte Carlo",         
  "skoda--fabia--hatch_5d_scout"                => "hatch_5d Scout",               
  "skoda--octavia--crossover_scout"             => "wagon Scout",
  "skoda--roomster--minivan_scout"              => "minivan Scout",
  "ssangyong--rexton--suv_7_seats"              => "suv 7 seats",                  
  "toyota--rav4--crossover_long"                => "crossover Long",               
  "uaz--2206--van_long"                         => "van Long",
  "uaz--2360--suv_cargo"                        => "pickup Cargo",                    
  "uaz--2360--suv_patriot"                      => "pickup Patriot",                  
  "uaz--3160--suv_5d_simbir"                    => "suv_5d Simbir",                
  "uaz--3303--suv_330364"                       => "van 330364",                   
  "uaz--3303--suv_330394"                       => "van 330394",                   
  "uaz--patriot--suv_sport"                     => "suv Sport",                    
  "volkswagen--caddy--minivan_kombi"            => "minivan Kombi",                
  "volkswagen--caddy--minivan_kombi_maxi"       => "minivan Kombi Maxi",           
  "volkswagen--caddy--minivan_maxi"             => "minivan Maxi",                 
  "volkswagen--caddy--van_kasten"               => "van Kasten",                   
  "volkswagen--caddy--van_kasten_maxi"          => "van Kasten Maxi",              
  "volkswagen--golf--hatch_5d_r_line"           => "hatch_5d R-Line",    
}

Attributes_Vendor_Name = Translations_Vendors.invert

Attributes_Model_Name = {
  "land_rover--range_rover"        => "Range Rover",
  "land_rover--range_rover_evoque" => "Range Rover Evoque",
  "land_rover--range_rover_sport"  => "Range Rover Sport",    
}

Attributes_Model_BrandedName = {
  "land_rover--range_rover"        => "Range Rover",
  "land_rover--range_rover_evoque" => "Range Rover Evoque",
  "land_rover--range_rover_sport"  => "Range Rover Sport",  
}

Rus_CountryName_Codes = {
  "Австрия"        => "AT",
  "Бельгия"        => "BE",
  "Бразилия"       => "BR",
  "Великобритания" => "GB",
  "Венгрия"        => "HU",
  "Германия"       => "DE",
  "Индия"          => "IN",
  "Иран"           => "IR",
  "Испания"        => "ES",
  "Италия"         => "IT",
  "Канада"         => "CA",
  "Китай"          => "CN",
  "Южная Корея"    => "KR",
  "Мексика"        => "MX",
  "Нидерланды"     => "NL",
  "Польша"         => "PL",
  "Россия"         => "RU",
  "США"            => "US",
  "Словакия"       => "SK",
  "Таиланд"        => "TH",
  "Турция"         => "TR",
  "Узбекистан"     => "UZ",
  "Украина"        => "UA",
  "Франция"        => "FR",
  "Чехия"          => "CZ",
  "Швеция"         => "SE",
  "Япония"         => "JP",
}

Rus_Months = %w(Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь)
