desc "Run a crawler processor action, eg: rake app:crawler[action_name]"
task 'crawler', [:action] do |t, args|
  action = args[:action]
  raise "No action specified" unless action

  require "#{Dir.pwd}/crawler/ya2_boot.rb"
  worker = action.start_with?("step_8") ? YA2Parser : YA2Processor
  worker.new.send(action)
end

desc "Run a crawler parser action, eg: rake app:crawler:parser[action_name]"
task 'crawler:parser', [:action] do |t, args|
  raise "No action specified" unless args[:action]
  require "#{Dir.pwd}/crawler/ya2_boot.rb"
  YA2Parser.new.send( args[:action] )
end

task meta: %w(crawler:step_83 crawler:copy) do
end


namespace 'crawler' do
  rule "" do |action|
    if action.name.start_with?('crawler:step')
      require "#{Dir.pwd}/crawler/ya2_boot.rb"      
      method = action.name.split(':').last
      worker = method.start_with?("step_8") ? YA2Parser : YA2Processor
      puts "-- #{method}"
      worker.new.send(method)
    else
      puts "unknown task: #{action.name}"
    end
  end
  
  # desc "Rebuild metadata from raw files"
  # task :meta do
  #   require File.dirname(__FILE__) + "/crawler/ya_init.rb"
  #   puts Benchmark.realtime { $ya_final_parser.build_metadata }
  #   system "cp tmp/gen/db-metadata.plist resources/"
  # end
  #
  # desc "Rebuild mods list from raw files"
  # task :mods do
  #   require File.dirname(__FILE__) + "/crawler/ya_init.rb"
  #   $ya_number_of_mods_to_convert = ENV['N'].to_i if ENV['N']
  #   puts Benchmark.realtime { $ya_final_parser.build_modifications }
  #   system "cp tmp/gen/db-mods.plist resources/tmp/"
  # end
  #
  # desc "Load everything"
  # task :work do
  #   require File.dirname(__FILE__) + "/crawler/ya_init.rb"
  #   $ya_final_analyzer.work
  # end
  
  task :copy do
    system "cp /opt/work/carchartscrawler/data_1502/08.2-mods.plist resources/db/mods.plist"
    system "cp /opt/work/carchartscrawler/data_1502/08.3-metadata.plist resources/db/metadata.plist"
  end
end
