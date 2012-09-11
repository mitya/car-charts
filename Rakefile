$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

Motion::Project::App.setup do |app|
  app.name = 'CarCharts'
  app.identifier = "name.sokurenko.CarCharts"
  app.version = "0.1"
  app.icons = ["ico-app-iphone.png", "ico-app-iphone@2x.png"]
  # app.deployment_target = "5.0"
  # app.frameworks += ['AVFoundation']
  # app.device_family = [:ipad, :iphone]
end

src_dir = "assets"
dst_dir = "resources"
tmp_dir = "tmp"
icons = %w(categories parameters)

task :icons do
  icons.each do |icon|
    icon = "#{icon}_icon"
    system "convert #{src_dir}/#{icon}.png -alpha Off -negate #{tmp_dir}/#{icon}_neg.png"
    system "convert #{src_dir}/#{icon}.png #{tmp_dir}/#{icon}_neg.png -alpha Off -compose Copy_Opacity -composite #{dst_dir}/#{icon}@2x.png"
  end
end

# convert -list font | grep Font:
task :appicon do
  label = "Cc"
  options = "-background blue -fill white -font LuxiSansB -gravity center"
  system "convert #{options} -size   57x57 -pointsize 40 label:#{label} resources/icon_iphone.png"
  system "convert #{options} -size 114x114 -pointsize 80 label:#{label} resources/icon_iphone@2x.png"
end

task :letters do
  letters = ENV['TEXT']
  size = ENV['SIZE'] || '60'
  # -pointsize 40
  # color = size == '60' ? "'rgb(230,80,70)'" : "white"
  color = "white"
  system "convert -background transparent -fill #{color} -font Bookman-Demi -gravity center -size #{size}x#{size} label:#{letters} #{dst_dir}/#{letters}@2x.png"
end

task :buttons do
  size = 60
  corners = 10
  
  items = [
    %w(blue #8aa1bf-#6682aa #466999-#486b9b #3b4f6b),
    %w(bluehigh #7298e9-#1f56c1 #2160dd-#2362de #163f91)
  ]    
  
  items.each do |data|
    name = data[0]
    gradient1 = data[1]
    gradient2 = data[2]
    border = data[3]
  
    cmd = %{ convert
      -size #{size}x#{size/2} gradient:#{gradient1} -size #{size}x#{size/2} gradient:#{gradient2} -append
      ( +clone -threshold -1
         -draw "fill black polygon 0,0 0,#{corners} #{corners},0 fill white circle #{corners},#{corners} #{corners},0"
         ( +clone -flip ) -compose Multiply -composite ( +clone -flop ) -compose Multiply -composite )
      +matte -compose CopyOpacity -composite
      -stroke #{border} -strokewidth 2 -fill transparent -draw "roundRectangle 0,0 #{size-1},#{size-1} #{corners},#{corners}" 
      resources/button_#{name}@2x.png
      }.gsub(/\s+/, " ").gsub(/[\(\)#]/) { |c| "\\#{c}" }

    system cmd 
  end
end

task :split_images do
  # convert resources/UISegmentOptionsDivider@2x.png -gravity East -crop 50%x100%+0+0 +repage resources/UISegmentOptionsDivider@2x.png
  
  [
    %w(resources/ui-multisegment resources/ui-multisegment-divider@2x.png),
    %w(resources/ui-multisegment-selected resources/ui-multisegment-selected-divider@2x.png)
  ].each do |file, border|
    system "convert #{file}-base@2x.png -gravity West  -crop 50%x100%+0+0 +repage #{border} +append #{file}-left@2x.png"
    system "convert #{border} #{file}-base@2x.png -gravity North -crop 4x60+0+0     +repage #{border} +append #{file}-mid@2x.png"
    system "convert #{border} #{file}-base@2x.png -gravity East  -crop 50%x100%+0+0 +repage +append #{file}-right@2x.png"
  end
end

# $images = "data/images"
# $sources = "artefacts/images"
# 
# $gradients = {
#   red: %w(f00 e00),
#   green: %w(0c0 0b0),
#   yellow: %w(ff0 ee0),  
#   gray: %w(ccc eee)
# }
# 
# task :cellbg do
#   colors = {
#     red: %w(f00 c00),
#     green: %w(0a0 080),
#     yellow: %w(ff0 dd0),
#     gray: %w(eee ddd),
#     blue: %w(daeafa e0f0ff)
#   }
# 
#   basename = "cell-bg"
#   height = 45
#   
#   colors.each_pair do |name, color|
#     gradient = "gradient:##{color.first}-##{color.last}"
#     system %[convert -size 1x#{height} #{gradient} #{$images}/#{basename}-#{name}.png]
#     system %[convert -size 1x#{height*2} #{gradient} #{$images}/#{basename}-#{name}@2x.png]
#   end  
# 
#   colors.each_pair do |name, color| 
#     # gradient = "radial-gradient:##{color.first}-##{color.last}"
#     gradient = "radial-gradient:##{color.last}-##{color.first}"
#     system %[convert -size 1x#{height} #{gradient} #{$images}/#{basename}r-#{name}.png]
#     system %[convert -size 1x#{height*2} #{gradient} #{$images}/#{basename}r-#{name}@2x.png]
#   end
# end
# 
# task :pins do
#   basename = "crossing-pin"
#   # `cp ~/desktop/marker.001.png artefacts/images/#{basename}-red.png`
#   # `cp ~/desktop/marker.002.png artefacts/images/#{basename}-yellow.png`
#   # `cp ~/desktop/marker.003.png artefacts/images/#{basename}-green.png`
#   
#   colors = %w(red green yellow)
#   colors.each do |color|
#     source = "#{$sources}/#{basename}-#{color}.png"
#     `convert #{source} -fuzz 15% -transparent "rgb(213, 250, 128)" #{source}`
#     `convert #{source} -background transparent -gravity north -extent 200x400 #{source}`
#     `convert #{source} -resize 30x60 #{$images}/#{basename}-#{color}.png`
#     `convert #{source} -resize 60x120 #{$images}/#{basename}-#{color}@2x.png`
#   end 
# end
# 
# task :stripes do
#   gradients = {
#     red: %w(f00 e00),
#     green: %w(0c0 0b0),
#     yellow: %w(ff0 ee0),  
#   }
#   gradients.each_pair do |color_name, color_string| 
#     `convert -size 15x44 xc:transparent -fill radial-gradient:##{color_string.first}-##{color_string.last} -draw 'rectangle 8,0 15,44' data/images/cell-stripe-#{color_name}.png`
#     `convert -size 30x88 xc:transparent -fill radial-gradient:##{color_string.first}-##{color_string.last} -draw 'rectangle 16,0 30,88' data/images/cell-stripe-#{color_name}@2x.png`
# 
#     # `convert -size 6x44 xc:transparent -fill gradient:##{color_string.last}-##{color_string.first} -draw 'roundRectangle 0,5 5,38 1,1' data/images/cell-gradient-#{color_name}.png`
#     # `convert -size 30x44 xc:transparent -fill gradient:##{color_string.last}-##{color_string.first} -draw 'circle 15,22 2,22' data/images/cell-gradient-#{color_name}.png`
#     # `convert -size 20x44 radial-gradient:##{color_string.last}-##{color_string.first} data/images/cell-gradient-#{color_name}.png`
#     # `convert -size 6x44 radial-gradient:##{color_string.first}-##{color_string.last} data/images/cell-gradient-#{color_name}.png`    
#   end
# end
