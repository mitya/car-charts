$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'rubygems'
require 'color'

Motion::Project::App.setup do |app|
  app.name = 'CarCharts'
  app.identifier = "name.sokurenko.CarCharts"
  app.version = "0.1"
  app.icons = ["ico-app-iphone.png", "ico-app-iphone@2x.png"]
  # app.deployment_target = "5.0"
  # app.frameworks += ['AVFoundation']
  # app.device_family = [:ipad, :iphone]
end

src_dir = "assets"; dst_dir = "resources"; tmp_dir = "tmp"
icons = %w(categories parameters)

def hsb(hue, sat, val)
  hue = hue / 360.0; sat = sat / 100.0; val = val / 100.0

  lum = (2 - sat) * val
  sat = sat * val
  sat /= lum <= 1.0 ? lum : 2 - lum
  lum /= 2.0

  color = Color::HSL.new(hue * 360, sat * 100, lum * 100)

  # "hsb(#{h}, #{(s / 100.0 * 255).to_i}, #{(b / 100.0 * 255).to_i})"
  color.to_rgb.html
end

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
  letters = ENV['TEXT']; size = ENV['SIZE'] || '60'
  # -pointsize 40 # color = size == '60' ? "'rgb(230,80,70)'" : "white"
  system "convert -background transparent -fill white -font Bookman-Demi -gravity center -size #{size}x#{size} label:#{letters} #{dst_dir}/#{letters}@2x.png"
end

task :toolbar_bg do
  # colors = [hsb(214, 32, 63), hsb(214, 32, 50)] # blue
  colors = [hsb(200, 5, 88), hsb(203, 9, 78)] # gray
  system "convert -size 2x86 -colorspace hsb gradient:'#{colors.join("-")}' -size 2x2 xc:#333 -append resources/bg-toolbar-under@2x.png"
end

task :buttons do
  size = 60; corners = 10
  
  items = [
    %w(blue #8aa1bf-#6682aa #466999-#486b9b #3b4f6b),
    %w(bluehigh #7298e9-#1f56c1 #2160dd-#2362de #163f91)
  ]    
  
  items.each do |data|
    name, gradient1, gradient2, border = data  
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
  [
    %w(resources/ui-multisegment resources/ui-multisegment-divider@2x.png),
    %w(resources/ui-multisegment-selected resources/ui-multisegment-selected-divider@2x.png)
  ].each do |file, border|
    system "convert #{file}-base@2x.png -gravity West  -crop 50%x100%+0+0 +repage #{border} +append #{file}-left@2x.png"
    system "convert #{border} #{file}-base@2x.png -gravity North -crop 4x60+0+0     +repage #{border} +append #{file}-mid@2x.png"
    system "convert #{border} #{file}-base@2x.png -gravity East  -crop 50%x100%+0+0 +repage +append #{file}-right@2x.png"
  end
end
