require "rubygems"
require "open-uri"
require "pathname"
require "json"
require 'yaml'
require "ostruct"
require "pp"
require "benchmark"
require "set"
require "csv"

# require "nokogiri"
# require "plist"

# require "fileutils"
# require "russian"

require File.dirname(__FILE__) + "/ya2_helper.rb"
require File.dirname(__FILE__) + "/ya2_data.rb"
require File.dirname(__FILE__) + "/ya2_processor.rb"
require File.dirname(__FILE__) + "/ya2_parser.rb"
require File.dirname(__FILE__) + "/data.rb"

WORKDIR = Pathname("/opt/work/carchartscrawler/data_1502")
YA_HOST = "https://auto.yandex.ru"

def xprintf(*args)
  
end
