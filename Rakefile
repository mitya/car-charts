# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

# ENV['device_name'] = 'Resizable iPad'

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
end

load 'scripts/crawler.rake'
load 'scripts/graphics.rake'

task :iphone5  do ENV['device_name'] = 'iPhone 5s';      Rake::Task['simulator'].invoke end
task :iphone6  do ENV['device_name'] = 'iPhone 6';       Rake::Task['simulator'].invoke end
task :iphone6p do ENV['device_name'] = 'iPhone 6 Plus';  Rake::Task['simulator'].invoke end
task :ipad     do ENV['device_name'] = 'Resizable iPad'; Rake::Task['simulator'].invoke end
task d: 'device'
