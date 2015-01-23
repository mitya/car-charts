require "rubygems"
require "nokogiri"
require "open-uri"
require "pathname"
require "json"
require 'yaml'
require "ostruct"
# require "benchmark"
# require "pp"
# require "fileutils"
# require "russian"
# require "set"
# require "plist"

require File.dirname(__FILE__) + "/ya2_helper.rb"
require File.dirname(__FILE__) + "/ya2_parser_homepage.rb"

WORKDIR = Pathname("#{Dir.pwd}/crawler_data")
YA_HOST = "http://auto.yandex.ru"
