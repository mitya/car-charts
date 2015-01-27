require "rubygems"
require "nokogiri"
require "open-uri"
require "pathname"
require "json"
require 'yaml'
require "ostruct"
require "pp"
require "benchmark"
require "set"
require "csv"
# require "fileutils"
# require "russian"
# require "plist"

require File.dirname(__FILE__) + "/ya2_helper.rb"
require File.dirname(__FILE__) + "/ya2_data.rb"
require File.dirname(__FILE__) + "/ya2_processor.rb"

WORKDIR = Pathname("/opt/work/carchartscrawler/data_1502")
YA_HOST = "http://auto.yandex.ru"
