desc "Run a crawler processor action, eg: rake app:crawler[action_name]"
task 'cc', [:action] do |t, args|
  action = args[:action]
  raise "No action specified" unless action

  require "#{Dir.pwd}/crawler/ya2_boot.rb"
  worker = action.start_with?("step_8") ? YA2Parser : YA2Processor
  worker.new.send(action)
end

desc "Run a crawler parser action, eg: rake app:cc:parser[action_name]"
task 'cc:parser', [:action] do |t, args|
  raise "No action specified" unless args[:action]
  require "#{Dir.pwd}/crawler/ya2_boot.rb"
  YA2Parser.new.send( args[:action] )
end

task meta: %w(cc:step_83 cc:copy) do
end


namespace 'cc' do
  rule "" do |action|
    if action.name =~ /cc:\d.*/
      require "#{Dir.pwd}/crawler/ya2_boot.rb"      
      method = action.name.split(':').last
      worker = method.start_with?("8") ? YA2Parser : YA2Processor
      worker.new.send("step_#{method}")
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
    system "cp /opt/work/carchartscrawler/data_1504/82-mods.plist resources/db/mods.plist"
    system "cp /opt/work/carchartscrawler/data_1504/83-metadata.plist resources/db/metadata.plist"
  end
end
