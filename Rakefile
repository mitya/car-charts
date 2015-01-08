# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

ENV['device_name'] ||= 'iPhone 6 Plus'

Motion::Project::App.setup do |app|
  app.name = 'CarCharts'
  app.identifier = "name.sokurenko.CarCharts"
  app.version = "1.0"
  app.icons = %w(Icon-60 Icon-76 Icon-Small-40 Icon-Small)
  app.sdk_version = "8.1"
  app.deployment_target = "7.0"
  app.libs += ['/usr/lib/libsqlite3.dylib']
  app.detect_dependencies = false
  app.frameworks += ['CoreData']
  app.device_family = [:iphone, :ipad]
  app.provisioning_profile = '/Volumes/Vault/Sources/active/_profiles/iOS_Team_Provisioning_Profile_.mobileprovision'
  
  # app.info_plist['CFBundleURLTypes'] = [
  #   { 'CFBundleURLName' => 'com.mycompany.x-videoplayer', 'CFBundleURLSchemes' => ['x-videoplayer'] }
  # ]
  
  # app.pods do
  #   pod 'FMDB'
  # end
end

load 'scripts/crawler.rake'
load 'scripts/graphics.rake'

