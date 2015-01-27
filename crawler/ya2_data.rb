module CWD
  Reductions_Body_Body = {
    [:mercedes, 'универсал Shooting Brake'] => 'универсал',
    [:land_rover, 'внедорожник 3 дв. 90'] => 'внедорожник 3 дв.',
    [:opel, 'хэтчбек 3 дв. GTC'] => 'хэтчбек 3 дв.',
    [:opel, 'универсал Sports Tourer'] => 'универсал',
    [:kia, 'хэтчбек 3 дв. pro_cee\'d'] => 'хэтчбек 3 дв.',
    [:volkswagen, 'пикап 2 дв. Single Cab'] => 'пикап 2 дв.',
    [:hyundai, 'седан Limusine'] => 'седан Long',
    [:mercedes, 'седан AMG Long'] => 'седан Long',
  }
  
  Reductions_Body_Model = {
    ['volkswagen passat 2011', 'универсал Alltrack'] => 'volkswagen passat_alltrack 2011 wagon'
    # stepway
  }

  Bodies = {
    "седан"             => :sedan,
    "седан Long"        => :sedan_long,
    "универсал"         => :wagon,
    "хэтчбек 3 дв."     => :hatch_3d,
    "хэтчбек 5 дв."     => :hatch_5d,
    "купе"              => :coupe,
    "кабриолет"         => :cabrio,
    "кроссовер"         => :crossover,
    "кроссовер 3 дв."   => :crossover_3d,
    "вседорожник"       => :suv,
    "вседорожник 3 дв." => :suv_3d,
    "вседорожник 4 дв." => :suv_4d,
    "вседорожник 5 дв." => :suv_5d,
    "вседорожник Long"  => :suv_long,
    "минивен"           => :minivan,
    "пикап"             => :pickup,
    "пикап 2 дв."       => :pickup_2d,
    "пикап 4 дв."       => :pickup_4d,
                        
    "микроавтобус"      => :minibus,
    "фургон"            => :van,
  }  
end
