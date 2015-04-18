module KK::Logging
  # def flurry
  #   if Env::TRACKING_FLURRY
  #     @flurry ||= Flurry
  #   else
  #     nil
  #   end
  # end
  #
  # def trackUI(action, label=nil)
  #   track :ui, action, label
  # end
  #
  # def trackSystem(action, label=nil)
  #   track :sys, action, label
  # end
  #
  # def track(category, action, label=nil)
  #   return unless Env::TRACKING
  #
  #   action_name = "#{category}:#{action}"
  #   label = label.to_tracking_key if label && label.respond_to?(:to_tracking_key)
  #
  #   if gai
  #     gai.send GAIDictionaryBuilder.createEventWithCategory(category.to_s, action: action.to_s, label: label, value: nil).build
  #   end
  #
  #   if flurry
  #     if label
  #       flurry_params = {'label' => label}
  #       flurry.logEvent action_name, withParameters:flurry_params
  #     else
  #       flurry.logEvent action_name
  #     end
  #   end
  #
  #   debug "EVENT #{action_name} [#{label}]" if DEBUG
  # end
  #

  def trackEvent(eventName, object = nil)
    return unless FLURRY_ENABLED
    
    params = case object
      when Hash then object
      when nil then nil
      else { value: object.to_s }
    end
    Flurry.logEvent eventName, withParameters: params
    
    debug "event #{eventName} #{object}" if DEBUG
  end
  
  def trackControllerView(controller)
    return unless FLURRY_ENABLED

    if defined? controller.class::ScreenKeyMethod
      screenKeyMethod = controller.class::ScreenKeyMethod
      screenKeyObject = controller.send(screenKeyMethod)
    elsif controller.respond_to?(:screenKey)
      screenKeyObject = controller.screenKey
    end
    screenName = controller.class.name.sub('Controller', '')
    trackScreen screenName, screenKeyObject
  end
  
  def trackScreen(screenName, object = nil)
    return unless FLURRY_ENABLED

    params = object ? { object: object.to_s } : nil
    Flurry.logPageView
    Flurry.logEvent "screen:#{screenName}", withParameters: params
    
    debug "show #{screenName} #{object}" if DEBUG
  end
end

KK.extend(KK::Logging)
