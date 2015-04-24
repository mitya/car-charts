# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

# /Applications/Developer/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/simctl list
ENV['device_name'] = 'iPad Retina 7.1'
ENV['device_name'] = 'iPhone 5s 7.1'
ENV['device_name'] = 'iPhone 6'
ENV['device_name'] = 'iPad Air'

Motion::Project::App.setup do |app|
  app.name = 'CarCharts'
  app.identifier = "name.sokurenko.CarCharts"
  app.icons = %w(Icon-60 Icon-76 Icon-40 Icon-Small)
  app.sdk_version = "8.3"
  app.deployment_target = "7.0"
  app.libs += ['/usr/lib/libsqlite3.dylib']
  app.detect_dependencies = false
  app.frameworks += %w(CoreData iAd)
  app.device_family = [:iphone, :ipad]
  app.vendor_project 'vendor/Flurry', :static, :products => ['libFlurry_6.2.0.a'], :headers_dir => 'Flurry.h', force_load: false
  app.info_plist['UIStatusBarStyle'] = 'UIStatusBarStyleLightContent'

  app.pods do
    pod 'EncryptedCoreData', :git => 'https://github.com/project-imas/encrypted-core-data.git'
    pod 'SQLCipher'
  end

  app.development do
    app.version = "1.0.100"
    app.codesign_certificate = "iPhone Developer: Dmitry Sokurenko (9HS3696XGX)"
    app.provisioning_profile = "/Volumes/Vault/Sources/active/_etc/Universal_Development_Profile.mobileprovision"
    app.redgreen_style = :full # default: :focused, also can use :progress
    app.info_plist['CCDebugMode'] = true
    # app.info_plist['CCNoAds'] = true
    # app.info_plist['CCNoResetAfterCrash'] = true
    # app.info_plist['CCBenchmarking'] = true
    # app.info_plist['CCTestModsDataset'] = true
    # app.info_plist['CCTestModsDatasetRun'] = true
  end

  app.release do
    app.version = "1.0.100"
    app.codesign_certificate = "iPhone Distribution: Dmitry Sokurenko (SQLB2GAZ2T)"
    # app.provisioning_profile = "/Volumes/Vault/Sources/active/_etc/AdHoc_Profile_for_AllegroTime.mobileprovision"

    if ENV['appstore'] == 'yes'
      app.version = "1.0.0"
      # app.provisioning_profile = "/Volumes/Vault/Sources/active/_etc/AppStore_Profile_for_AllegroTime.mobileprovision"
    end
  end
end

load 'scripts/crawler.rake'
load 'scripts/graphics.rake'

task '5'    do ENV['device_name'] = 'iPhone 5s';      Rake::Task['simulator'].invoke end
task '6'    do ENV['device_name'] = 'iPhone 6';       Rake::Task['simulator'].invoke end
task '6p'   do ENV['device_name'] = 'iPhone 6 Plus';  Rake::Task['simulator'].invoke end
task 'ipad' do ENV['device_name'] = 'iPad Air';       Rake::Task['simulator'].invoke end
task d: 'device'


task 'archive:distribution' do
  puts "remove the mods.plist !!!"
end
