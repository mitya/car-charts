$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'rubygems'
require 'color'

Motion::Project::App.setup do |app|
  app.name = 'CarCharts'
  app.identifier = "name.sokurenko.CarCharts"
  app.version = "0.1"
  app.icons = ["ico-app-iphone.png", "ico-app-iphone@2x.png"]
  app.deployment_target = "6.0"
  app.libs += ['/usr/lib/libsqlite3.dylib']
  app.frameworks += ['CoreData']
  # app.device_family = [:ipad, :iphone]
  
  # app.pods do
  #   pod 'FMDB'
  # end  
end

######################################################################################################

src_dir = "assets"; dst_dir = "resources"; tmp_dir = "tmp"
icons = %w(categories parameters)

def hsb(hue, sat, val)
  hue = hue / 360.0; sat = sat / 100.0; val = val / 100.0

  lum = (2 - sat) * val
  sat = sat * val
  sat /= lum <= 1.0 ? lum : 2 - lum
  lum /= 2.0

  color = Color::HSL.new(hue * 360, sat * 100, lum * 100)

  color.to_rgb.html
end

def hsbg(h1, s1, v1, h2, s2, v2)
  "#{hsb(h1, s1, v1)}-#{hsb(h2, s2, v2)}"
end

def lastGradientColor(colorString)
  colorString.split('-').last
end

def run(command, options = {})
  # puts command
  system command
end

def parseHSV(string)
  hsb(*string.split(/\s|\./).map(&:to_f))
end

def parseHSVGradient(string)
  color1, color2 = string.include?('-') ? string.split(/\s*\-\s*/) : [string, string]
  "#{parseHSV(color1)}-#{parseHSV(color2)}"
end

def rasterizeSVG(basename, size = 40)
  system "convert assets/#{basename}.svg -resize #{size}x#{size} resources/tmp/#{basename}@2x.png"
end

def makeBBIcon(input)
  system "convert #{input} #{input} -alpha Off -negate -alpha Off -compose Copy_Opacity -composite #{input}"    
end


######################################################################################################

task :icons do
  icons.each do |icon|
    icon = "#{icon}_icon"
    system "convert #{src_dir}/#{icon}.png -alpha Off -negate #{tmp_dir}/#{icon}_neg.png"
    system "convert #{src_dir}/#{icon}.png #{tmp_dir}/#{icon}_neg.png -alpha Off -compose Copy_Opacity -composite #{dst_dir}/#{icon}@2x.png"
  end
end

task :appicon do
  label = "Cc"
  options = "-background blue -fill white -font LuxiSansB -gravity center"
  system "convert #{options} -size   57x57 -pointsize 40 label:#{label} resources/icon_iphone.png"
  system "convert #{options} -size 114x114 -pointsize 80 label:#{label} resources/icon_iphone@2x.png"
end

# convert -list font | grep Font:
# rake letters text=Hey size=44
task :letters do
  letters = ENV['text']; size = ENV['size'] || '60'
  run "convert -background transparent -fill white -font Bookman-Demi -gravity center -size #{size}x#{size} label:#{letters} #{dst_dir}/#{letters}@2x.png"
end

task :toolbarbg do
  # colors = [hsb(200, 5, 88), hsb(203, 9, 78)] # [hsb(214, 32, 63), hsb(214, 32, 50)]
  # run "convert -size 2x86 -colorspace hsb gradient:'#{colors.join("-")}' -size 2x2 xc:#333 -append resources/bg-toolbar-under@2x.png"
  
  
  gradient = parseHSVGradient('214.21.75-214.53.55')
  run "convert -size 2x86 -colorspace hsb gradient:'#{gradient}' -size 2x2 xc:#333 -append resources/bg-button-1@2x.png"
end

# convert ico-bar.svg -resize 60x60 ico-bar.png
# convert ico-bar.png -background white -flatten ico-bar-2.png

task :icon_from_svg do
  basename, size = ENV['file'], ENV['size'] || 60
  temp = "resources/tmp/#{basename}@2x.png"
  system "convert assets/#{basename}.svg -resize #{size}x#{size} #{temp}"
  system "convert #{temp} #{temp} -alpha Off -negate -alpha Off -compose Copy_Opacity -composite #{temp}"
end

task :bbicon do
  input = ENV['in']
  system "convert #{input} #{input} -alpha Off -negate -alpha Off -compose Copy_Opacity -composite #{input.gsub('.png', 'BB@2x.png')}"
end

task :bbiconrun do
  rasterizeSVG "ico-gears", 40
  rasterizeSVG "ico-car", 40
  rasterizeSVG "ico-weight", 40
  
  makeBBIcon "resources/tmp/ico-gears@2x.png"
  makeBBIcon "resources/tmp/ico-car@2x.png"
  makeBBIcon "resources/tmp/ico-weight@2x.png"  
end

task :cellbutton do
  [
    %w[blue   214.21.75-214.53.55 218.75.55 214.18.76],
    %w[yellow 050.50.85-050.70.50 050.50.50 214.18.76],
  ].each do |name, gradient, borderClr, shadowClr|
    makeButton 26, 50, 12, parseHSVGradient(gradient), parseHSV(borderClr), parseHSV(shadowClr), "resources/bg-button-#{name}@2x.png",
      fullWidth:40, fullHeight:88
  end
end

task :buttons do
  sizes = [
    [nil, 60, 26, 12, 14],
    ["mini", 48, 24, 10, 12]
  ]

  items = [
    #        gradient               border       divider
    ## blue - dk.blue
    ['on',   '214.21.75-214.53.55', '213.35.42', '217.36.58-217.57.48'],
    ['off',  '214.16.80-214.37.60', '213.35.42', '216.26.66-215.44.56'],

    ## blue - br.blue
    # ['on',   '218.42.90-219.80.85', '218.75.55', '218.60.75-218.75.60'],
    # ['off',  '212.16.80-212.37.64', '213.35.42', '216.26.66-215.44.56'],

    ## br.blue - black
    # ['on',   '218.42.91-219.80.85', '218.75.55', '218.78.54-218.75.55'],
    # ['off',  '000.00.45-000.00.12', '000.00.18', '000.00.25-000.00.10'],

    ## red-green-yellow
    # ['none', '050.50.85-050.70.50', '050.50.50', '050.50.70-050.50.50'],
    # ['on',   '150.40.60-150.80.40', '150.70.40', '150.70.50-150.70.35'],
    # ['off',  '000.60.70-000.80.45', '000.70.50', '000.70.55-000.70.50'],
  ]    
  
  sizes.each do |sizeData|
    sizeName, height, width, cornerRad, halfWidth = sizeData
    heightWoShadow = height - 2
    halfHeightWoShadow = heightWoShadow / 2
        
    items.each do |data|
      name, gradient, borderCl, dividerGr = data
      gradient = parseHSVGradient(gradient)
      borderCl = parseHSV(borderCl)
      dividerGr = parseHSVGradient(dividerGr)
      dividerBottomCl = lastGradientColor(dividerGr)
      suffix = "ui-multisegment#{sizeName}-#{name}"
      baseFile = "resources/xx-#{suffix}-base@2x.png"
      borderFile = "tmp/#{suffix}-divider@2x.png"
    
      shadow = parseHSV('214 18 76')
      borderShadow = parseHSV('214 25 70')

      # -size #{width}x#{halfHeightWoShadow} gradient:#{topGr} -size #{width}x#{halfHeightWoShadow} gradient:#{bottomGr} -append

      makeButton width, height, cornerRad, gradient, borderCl, shadow, baseFile

      run "convert -size 1x1 xc:#{borderCl} -size 1x#{heightWoShadow-2} gradient:#{dividerGr} -size 1x1 xc:#{borderCl} -size 1x2 xc:#{borderShadow} -append #{borderFile}"
      run "convert #{baseFile} -gravity West -crop #{halfWidth}x#{height}+0+0 +repage #{borderFile} +append resources/#{suffix}-left@2x.png"
      run "convert #{borderFile} #{baseFile} -gravity North -crop 4x#{height}+0+0  +repage #{borderFile} +append resources/#{suffix}-mid@2x.png"
      run "convert #{borderFile} #{baseFile} -gravity East -crop #{halfWidth}x#{height}+0+0 +repage +append resources/#{suffix}-right@2x.png"
    end
  end
end

task :d => :device
task :s do
  ENV['retina'] = '4'
  Rake::Task['simulator'].invoke
end

def makeButton(width, height, cornerRad, gradient, borderCl, shadowCl, file, options = {})
  heightWoShadow = height - 2
  fullWidth  = options[:fullWidth] || width
  fullHeight = options[:fullHeight] || height
  
  cmd = %{ convert
    -size #{width}x#{heightWoShadow} gradient:#{gradient} -sigmoidal-contrast 3,50%
    ( +clone -threshold -1
       -draw "fill black polygon 0,0 0,#{cornerRad} #{cornerRad},0 fill white circle #{cornerRad},#{cornerRad} #{cornerRad},0"
       ( +clone -flip ) -compose Multiply -composite ( +clone -flop ) -compose Multiply -composite )
    +matte -compose CopyOpacity -composite
    -size #{width}x#{heightWoShadow} xc:transparent +swap -gravity North -compose src-over -composite
    -stroke #{borderCl} -strokewidth 2 -fill transparent -draw "roundRectangle 0,0 #{width-1},#{heightWoShadow-1} #{cornerRad},#{cornerRad}" 
    ( +clone -background #{shadowCl} -shadow 50x0+0+2 ) +swap
    -background none -mosaic
    -size #{fullWidth}x#{fullHeight} xc:transparent +swap -gravity Center -compose src-over -composite
    #{file}
    }.gsub(/\s+/, " ").gsub(/[\(\)#]/) { |c| "\\#{c}" }
  run cmd
end


task :foo do
  list = %w(
  body version_subkey transmission drive engine_vol fuel power model_key
      valves_per_cylinder consumption_city max_power_kw cylinder_placement compression gross_mass bore doors compressor
      injection tires max_torque_range_start rear_brakes max_torque max_power stroke seats acceleration_0_100_kmh consumption_highway
      engine_spec consumption_mixed countries fuel_rating height drive_config produced_since rear_tire_rut engine_title luggage_min
      length engine_volume body_type max_power_range_start kerbweight fuel car_class ground_clearance luggage_max front_suspension
      price tank_capacity wheelbase model_title front_brakes engine_placement rear_suspension top_speed gears width front_tire_rut
      cylinder_count transmission body_title produced_till max_torque_range_end max_power_range_end version base_model_key fixed_model_name
  )
  
  list.each do |prop|
    puts "[#{"'#{prop}',".ljust(25)} NSStringAttributeType, false],"
  end
end

desc "Run the simulator"
task :simulator2 => ['build:simulator'] do
  app = App.config.app_bundle('iPhoneSimulator')
  target = ENV['target'] || App.config.sdk_version

  # Cleanup the simulator application sandbox, to avoid having old resource files there.
  if ENV['clean']
    sim_apps = File.expand_path("~/Library/Application Support/iPhone Simulator/#{target}/Applications")
    Dir.glob("#{sim_apps}/**/*.app").each do |app_bundle|
      if File.basename(app_bundle) == File.basename(app)
        rm_rf File.dirname(app_bundle)
        break
      end  
    end
  end

  # Prepare the device family.
  family_int =
    if family = ENV['device_family']
      App.config.device_family_int(family.downcase.intern)
    else
      App.config.device_family_ints[0]
    end
  retina = ENV['retina']

  # Configure the SimulateDevice variable (the only way to specify if we want to run in retina mode or not).
  simulate_device = App.config.device_family_string(family_int, target, retina)
  if `/usr/bin/defaults read com.apple.iphonesimulator "SimulateDevice"`.strip != simulate_device
    system("/usr/bin/killall \"iPhone Simulator\" >& /dev/null")
    system("/usr/bin/defaults write com.apple.iphonesimulator \"SimulateDevice\" \"'#{simulate_device}'\"")
  end

  # Launch the simulator.
  xcode = App.config.xcode_dir
  env = xcode.match(/^\/Applications/) ? "DYLD_FRAMEWORK_PATH=\"#{xcode}/../Frameworks\":\"#{xcode}/../OtherFrameworks\"" : ''
  env << ' SIM_SPEC_MODE=1' if App.config.spec_mode
  sim = File.join(App.config.bindir, 'sim')
  debug = (ENV['debug'] ? 1 : (App.config.spec_mode ? '0' : '2'))
  App.info 'Simulate', app
  at_exit { system("stty echo") } if $stdout.tty? # Just in case the simulator launcher crashes and leaves the terminal without echo.
  command = "#{env} #{sim} #{debug} #{family_int} #{target} \"#{xcode}\" \"#{app}\" \"-com.apple.CoreData.SQLDebug 1\""
  puts command
  sh command
end

# -com.apple.CoreData.SQLDebug 1
