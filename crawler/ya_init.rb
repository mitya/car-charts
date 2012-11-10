require File.dirname(__FILE__) + "/boot.rb"
require File.dirname(__FILE__) + "/data.rb"
require File.dirname(__FILE__) + "/data_classes.rb"
require File.dirname(__FILE__) + "/ya_helper.rb"
require File.dirname(__FILE__) + "/ya_loader.rb"
require File.dirname(__FILE__) + "/ya_source_parser.rb"
require File.dirname(__FILE__) + "/ya_final_parser.rb"
require File.dirname(__FILE__) + "/ya_final_analyzer.rb"

WORKDIR = Pathname("/opt/work/carchartscrawler/data")
OUTDIR = Pathname("/opt/work/carcharts/tmp/gen")
PRODDIR = "/opt/work/carcharts/resources"
YA_ROOT = "http://auto.yandex.ru"

$ya_loader = YALoader.new
$ya_source_parser = YASourceParser.new
$ya_final_parser = YAFinalParser.new
$ya_final_analyzer = YAFinalAnalyzer.new
