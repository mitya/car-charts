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

Dir.glob("#{File.dirname(__FILE__)}/ya2_*.rb") { |file| require file }
require File.dirname(__FILE__) + "/data.rb"

WORKDIR = Pathname("/opt/work/carchartscrawler/data_1504")
YA_HOST = "https://auto.yandex.ru"

def xprintf(*args) end
def xputs(*args) end
def xvalidate(&block) end
def validate(&block) yield end

def __p(*args)
  puts args.map(&:inspect).join('  ')
end
