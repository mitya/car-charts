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

def run(command, options = {})
  # puts command
  system command
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
  colors = [hsb(200, 5, 88), hsb(203, 9, 78)] # [hsb(214, 32, 63), hsb(214, 32, 50)]
  run "convert -size 2x86 -colorspace hsb gradient:'#{colors.join("-")}' -size 2x2 xc:#333 -append resources/bg-toolbar-under@2x.png"
end

# convert noun_project_2542.svg -resize 44x44 noun_project_2542.png
# convert in.png -background white -flatten out.png
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

def parseHSV(string)
  hsb(*string.split(' ').map(&:to_f))
end

def parseHSVGradient(string)
  color1, color2 = string.split(' - ')
  "#{parseHSV(color1)}-#{parseHSV(color2)}"
end

task :buttons do
  size = 60; width = 26; corners = 12
  height = 60
  heightNoShadow = height - 2
  hw = 14
  
  
  # 214 27 38 - segment control border (one of)
  # 214 18 76 - segment control default top top
  # 213 24 71 - segment control default top bottom
  # 213 28 69 - segment control default bottom
  # 213 28 75 - segment control selected top top
  # 214 45 65 - segment control selected top bottom
  # 215 53 60 - segment control selected bottom
  # 215 41 61 - segment control border top half (act. light gradient)
  # 215 68 49 - segment control border bottom half

  # 220 49 90 - Done button top top
  # 220 75 88 - Done button top bottom
  # 220 85 87 - Done button bottom
  # 220 74 56 - Done button border
  
  # 201 05 87 - gray top
  # 206 08 80 - gray bottom
  # 210 17 58 - gray border
  # 240 00 78 - gray border 2 top
  # 000 00 59 - gray border 2 bottom

  items = [
    ['normal', '214 18 76 - 213 24 71', '213 28 69 - 213 28 69', '214 27 38', '214 27 38 - 214 27 38'],
    ['inactive', '220 49 90 - 220 75 88', '220 85 87 - 220 85 87', '220 74 56', '220 74 56 - 220 74 56'],
    ['selected', '201 05 90 - 201 05 83', '206 08 80 - 206 08 80', '210 17 58', '210 17 58 - 210 17 58']
  ]    
  
  items.each do |data|
    name, gradient1, gradient2, border, divider = data
    gradient1 = parseHSVGradient(gradient1)
    gradient2 = parseHSVGradient(gradient2)
    border = parseHSV(border)
    divider = parseHSVGradient(divider)
    name = "xui-multisegment-#{name}"
    baseFile = "resources/#{name}-base@2x.png"
    borderFile = "tmp/#{name}-divider@2x.png"
    
    shadow = parseHSV('214 18 76')
    borderShadow = parseHSV('214 25 70')
    
    cmd = %{ convert
      -size #{width}x#{heightNoShadow/2} gradient:#{gradient1} -size #{width}x#{heightNoShadow/2} gradient:#{gradient2} -append
      ( +clone -threshold -1
         -draw "fill black polygon 0,0 0,#{corners} #{corners},0 fill white circle #{corners},#{corners} #{corners},0"
         ( +clone -flip ) -compose Multiply -composite ( +clone -flop ) -compose Multiply -composite )
      +matte -compose CopyOpacity -composite
      -size #{width}x#{heightNoShadow} xc:transparent +swap -gravity North -compose src-over -composite
      -stroke #{border} -strokewidth 2 -fill transparent -draw "roundRectangle 0,0 #{width-1},#{heightNoShadow-1} #{corners},#{corners}" 
      ( +clone -background #{shadow} -shadow 50x0+0+2 ) +swap
      -background none -mosaic
      #{baseFile}
      }.gsub(/\s+/, " ").gsub(/[\(\)#]/) { |c| "\\#{c}" }

    run cmd
    run "convert -size 1x#{height-2} -colorspace hsb gradient:'#{divider}' -size 1x2 xc:#{borderShadow} -append #{borderFile}"
    
    run "convert #{baseFile} -gravity West -crop #{hw}x#{height}+0+0 +repage #{borderFile} +append resources/#{name}-left@2x.png"
    run "convert #{borderFile} #{baseFile} -gravity North -crop 4x#{size}+0+0  +repage #{borderFile} +append resources/#{name}-mid@2x.png"
    run "convert #{borderFile} #{baseFile} -gravity East -crop #{hw}x#{height}+0+0 +repage +append resources/#{name}-right@2x.png"
  end
end
