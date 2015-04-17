src = "resources/images_src"
dst = "resources/images"
tmp = "tmp"
icons = %w(categories parameters)
wsrc = "resources/images/wipsrc"
wdst = "resources/images/wip"

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

def rake(task, params = {})
  params.each { |key, value| ENV[key.to_s] = value }  
  Rake::Task[task.to_s].invoke
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

def outfile(infile)
  case infile
  when /@2x\.png/
    infile.gsub('@2x.png', '-out@2x.png')
  when /\.png/
    infile.gsub('.png', '-out.png')
  else
    raise "non parseable file name #{infile}"
  end
end

namespace 'g' do
  desc "Make icons for tabs"
  task :icons do
    icons.each do |icon|
      icon = "#{icon}_icon"
      system "convert #{src_dir}/#{icon}.png -alpha Off -negate #{tmp_dir}/#{icon}_neg.png"
      system "convert #{src_dir}/#{icon}.png #{tmp_dir}/#{icon}_neg.png -alpha Off -compose Copy_Opacity -composite #{dst_dir}/#{icon}@2x.png"
    end
  end

  desc "Generate app icon"
  task :appicon do
    label = "Cc"
    
    options = "-background 'hsb(8.33%, 59%, 36%)' -fill white -font LuxiSansB -gravity center"
    system "convert #{options} -size 120x120 -pointsize 80 label:#{label} resources/icon_iphone@2x.png"
  end

  desc "Generate an icon with a letter, eg: rake letters text=Hey size=44"
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

  task :svg2png do
    input, output, size = ENV['in'], ENV['out'], ENV['size'] || 60
    system "convert -background transparent #{input} -resize #{size}x#{size} #{output}"
  end

  desc "Converts a B&W PNG icon inplace to the transparent BB icon. Eg: rake bbicon in=resources/tmp/bbi-back@2x.png"
  task :bbicon do
    input = ENV['in']
    system "convert #{input} #{input} -alpha Off -negate -alpha Off -compose Copy_Opacity -composite #{input}"
  end

  ## black with transparency
  # system "convert #{input} -negate #{output}"
  ## transparency + grayscale to grayscale
  # system "convert #{input} -background white -flatten +matte #{output}"
  ## grayscale to white + transparency
  # system "convert #{output} #{output} -alpha Off -negate -alpha Off -compose Copy_Opacity -composite -fx '#fff' #{output}"
  ## black with transparency
  # system "convert #{input} -alpha extract -alpha copy -fx '#fff' #{output}"

  desc "Takes PNGs from assets/wip, resizes them according to their type, and puts into resources/wip"
  task :rsti do
    Dir.glob("assets/wip/{bbi,tbi}*.png") do |src|
      basename = File.basename(src, '.png')
      prefix = basename[0..2]
      size = {bbi: 40, tbi: 60}[prefix.to_sym]
      file = "resources/wip/#{basename}@2x.png"
    
      # system "convert #{input} -background white -flatten +matte -resize #{size}x#{size} #{output}"
      # system "convert #{output} #{output} -alpha Off -negate -alpha Off -compose Copy_Opacity -composite -fx '#fff' #{output}"

      # system "convert #{input} -alpha copy -channel alpha -negate +channel -fx '#000' #{output}"
      # system "convert #{output} #{output} -alpha Off -negate -alpha Off -compose Copy_Opacity -composite #{output}"

      system "convert #{src} -background white -flatten #{file}"
      system "convert #{file} #{file} -negate -compose Copy_Opacity -composite -fx white #{file}"
      system "convert #{file} -filter point -resize #{size}x#{size} #{file}"
    end
  end

  desc "Just a main entry point for a random script"
  task :main do
    # run "rake svg2png in=assets/triangle.svg out=resources/tmp/triangle@2x.png size=40"
    run "rake bb_icon in=resources/tmp/bbi-forward@2x.png"
    run "rake bb_icon in=resources/tmp/bbi-back@2x.png"
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
      #         gradient               border       shadow       divider                divider-sh     
      ['on',   '210.15.60-210.99.20', '210.65.20', '210.40.50', '213.16.40-213.99.13', '210.58.42'], # dark blue
      ['off',  '000.00.70-000.00.20', '210.65.20', '210.40.50', '213.16.40-213.99.13', '210.58.42'], # gray

      # ['off',  '000.00.50-000.00.00', '210.65.20', '000.00.30', '213.16.40-213.99.13', '210.45.31'], # black
      # ['on',   '214.21.75-214.53.55', '213.35.42', '214 18 76', '217.36.58-217.57.48', '214 25 70'], # blue
      # ['off',  '214.16.80-214.37.60', '213.35.42', '214 18 76', '216.26.66-215.44.56', '214 25 70'], # dark blue
      # ['on',   '218.42.90-219.80.85', '218.75.55', '218.60.75-218.75.60'], # blue
      # ['off',  '212.16.80-212.37.64', '213.35.42', '216.26.66-215.44.56'], # bright blue
      # ['none', '050.50.85-050.70.50', '050.50.50', '050.50.70-050.50.50'], # yellow
      # ['on',   '150.40.60-150.80.40', '150.70.40', '150.70.50-150.70.35'], # green
      # ['off',  '000.60.70-000.80.45', '000.70.50', '000.70.55-000.70.50'], # red
    ]    
  
    sizes.each do |sizeData|
      sizeName, height, width, cornerRad, halfWidth = sizeData
      heightWoShadow = height - 2
      halfHeightWoShadow = heightWoShadow / 2
        
      items.each do |data|
        name, gradient, borderCl, shadowCl, dividerGr, dividerShadowCl = data
        gradient = parseHSVGradient(gradient)
        borderCl = parseHSV(borderCl)
        dividerGr = parseHSVGradient(dividerGr)
        dividerBottomCl = lastGradientColor(dividerGr)
        shadowCl = parseHSV(shadowCl)
        dividerShadowCl = parseHSV(dividerShadowCl)
        suffix = "ui-multisegment#{sizeName}-#{name}"
        baseFile = "resources/#{suffix}-base@2x.png"
        dividerFile = "tmp/#{suffix}-divider@2x.png"
    
        makeButton width, height, cornerRad, gradient, borderCl, shadowCl, baseFile
      
        run "convert -size 1x1 xc:#{borderCl} -size 1x#{heightWoShadow-2} gradient:#{dividerGr} -size 1x1 xc:#{borderCl} -size 1x2 xc:#{dividerShadowCl} -append #{dividerFile}"
        run "convert #{baseFile} -gravity West -crop #{halfWidth}x#{height}+0+0 +repage #{dividerFile} +append resources/#{suffix}-left@2x.png"
        run "convert #{dividerFile} #{baseFile} -gravity North -crop 4x#{height}+0+0  +repage #{dividerFile} +append resources/#{suffix}-mid@2x.png"
        run "convert #{dividerFile} #{baseFile} -gravity East -crop #{halfWidth}x#{height}+0+0 +repage +append resources/#{suffix}-right@2x.png"
      end
    end
  end

  task :make_empty do
    img_name = "ci-checkmarkStub@2x.png"
    img = Magick::Image.new(26, 20) { self.background_color = "transparent" }
    img.write "#{dst}/#{img_name}"
  end
    
  task :make do
    img_name = "ti-star@2x.png"
    img = Magick::Image.read("#{src}/#{img_name}").first
    # img = img.quantize 256, Magick::GRAYColorspace
    # img = img.transparent 'white'
    # img = img.scale(0.66)
    img = img.negate
    img.write "#{dst}/#{img_name}"
  end
  
  desc "removes the statusbar from a full-screen screenshot"
  task :chopstatus do    
    %w(Default@2x Default-568h@2x Default-667h@2x Default-736h@3x).each do |file|
      scale = file.scan(/@(\d)x/).first.first.to_i rescue 1
      statusbar_height = 20 * scale
      ss = Magick::Image.read("resources/#{file}.png").first
      ss.crop! 0, statusbar_height, ss.columns, ss.rows, true
      unless ENV['nofill']
        ss.background_color = "#404040"
        ss = ss.extent ss.columns, ss.rows + statusbar_height, 0, -statusbar_height
      end
      ss.write ss.filename
    end
  end
  
  
  task :pad_icon do
    pad = 5
    im = Magick::Image.read("resources/images/tt-selected@2x.png").first
    im.background_color = "transparent"
    im = im.extent im.columns, im.rows + pad, 0, -pad
    im.write outfile(im.filename)
  end  
  
  task :brands do
    dest = "resources/images/brands"
    sources = ['originals/brand_icons']

    sources.each do |folder|
      Dir.glob("#{folder}/*") do |path|
        basename = File.basename(path)
        FileUtils.cp path, File.expand_path(dest + '/' + basename.sub('.', '@2x.'))
        FileUtils.cp path, File.expand_path(dest + '/' + basename.sub('.', '@3x.'))
      end
    end
    
    sh "cd #{dest} && mogrify -path . -resize 80x -format png *@2x*"
    sh "cd #{dest} && mogrify -path . -resize 120x -format png *@3x*"
    sh "rm #{dest}/*.jpg"
  end
end
