namespace 'app:crawler' do
  desc "Rebuild metadata from raw files"
  task :meta do
    require File.dirname(__FILE__) + "/crawler/ya_init.rb"
    puts Benchmark.realtime { $ya_final_parser.build_metadata }
    system "cp tmp/gen/db-metadata.plist resources/"
  end

  desc "Rebuild mods list from raw files"
  task :mods do
    require File.dirname(__FILE__) + "/crawler/ya_init.rb"  
    $ya_number_of_mods_to_convert = ENV['N'].to_i if ENV['N']
    puts Benchmark.realtime { $ya_final_parser.build_modifications }
    system "cp tmp/gen/db-mods.plist resources/tmp/"
  end

  desc "Load everything"
  task :work do
    require File.dirname(__FILE__) + "/crawler/ya_init.rb"
    $ya_final_analyzer.work
  end
end