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
require "enumerator"
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

D10 = "10-models"
D12 = "12-mods-pass1n2"
D18 = "18-mods"
F11 = "11-models-1pass"
F11b = "11-models-2pass"
F13 = "13-models"
F13b = "13b-models"
F15 = "15-models"
F16 = "16-models"
F17 = "17-mods"
F17b = "17b-mods"
F81 = "81-mods"
F82 = "82-mods"
F83 = "83-metadata"

SHIT = Set.new %w(ac ariel bronto bufori byvin caterham changfeng coggiola dadi e_car ecomotors foton fuqi gonow gordon 
  hafei haima haval hawtai hindustan holden huanghai invicta iran_khodro liebao landwind lti mahindra marlin maruti
  morgan noble pagani panoz pgo panoz mitsuoka puch qoros spyker e_mobil)

MIN_YEAR = 2012
