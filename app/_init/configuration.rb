module Configuration
  module_function
    
  def tintColor
    colors[:tint]
  end
  
  def barTintColor
    KK.hsb(151,  0, 25)
  end
  
  def tabBarTintColor
    colors[:bar_bg]
  end
  
  def barIconColor
    colors[:bar_action]
  end
  
  def barTextColor
    colors[:bar_text]
  end
  
  def all_colors
    # digitalocean_blue_l = "205 82 75 A30"
    # items = digitalocean_blue_l.split(' ')
    # background = items.first(3).map(&:to_i)
    # action = items.last[1..-1].map(&:to_i)
    
    # digitalocean_blue_l = KK.hsb(205, 82, 75)
    # digitalocean_blue_d = KK.hsb(205, 74, 65)  # 30
    # things_blue = KK.hsb(213, 40, 69) # good
    # tcs_yellow = KK.hsb(50, 76, 100)
    # linode_green_l = KK.hsb(151, 67, 72) # good
    # linode_green_d = KK.hsb(149, 68, 65) # good
    
    # green back + green actions + white tabs
    # back = KK.hsb(149, 90, 30); action = KK.hsb(149, 30, 90); tint = KK.hsb(149, 50, 50) # good green

    @all_colors ||= {
      # brown: { tint: KK.hsb( 30, 99, 60), bar_bg: KK.hsb( 30, 99, 25), bar_action: KK.hsb( 30, 30, 85), bar_text: UIColor.whiteColor },
      # navy_gray:  { tint: KK.hsb(216, 16, 31), bar_bg: KK.hsb(216, 16, 31), bar_action: KK.hsb(216, 16, 90), bar_text: UIColor.whiteColor },
      # blue_1: { tint: KK.hsb(201, 63, 86), bar_bg: KK.hsb(201, 63, 86), bar_action: KK.hsb(201, 63, 40), bar_text: UIColor.whiteColor },
      # blue_2: { tint: KK.hsb(219, 63, 84), bar_bg: KK.hsb(219, 63, 84), bar_action: KK.hsb(219, 63, 30), bar_text: UIColor.whiteColor },
      # linode_green_l: { tint: linode_green_l, bar_bg: linode_green_l, bar_action: action_color, bar_text: UIColor.whiteColor },
      # linode_green_d: { tint: linode_green_d, bar_bg: linode_green_d, bar_action: action_color, bar_text: UIColor.whiteColor },
      # digitalocean_blue_d: { tint: digitalocean_blue_d, bar_bg: digitalocean_blue_d, bar_action: action_color, bar_text: UIColor.whiteColor },
      # things_blue: { tint: things_blue, bar_bg: things_blue, bar_action: action_color, bar_text: UIColor.whiteColor },
      # tcs_yellow: { tint: tcs_yellow, bar_bg: tcs_yellow, bar_action: tcs_yellow, bar_text: UIColor.blackColor },
      green_3: { tint: KK.hsb(151, 90, 70), bar_bg: KK.hsb(151,  0, 16), bar_action: KK.hsb(151, 30, 90), bar_text: UIColor.whiteColor },
    }    
  end
  
  def colors
    @colors ||= all_colors[:green_3]
  end
end
