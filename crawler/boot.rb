# encoding: utf-8

require "rubygems"
require "benchmark"
require "active_support/core_ext.rb"
require "pp"
require "nokogiri"
require "open-uri"
require "pathname"
require "json"
require "fileutils"
require "russian"
require "set"
require "ostruct"
require "plist"

class Nokogiri::HTML::Document
  def text_at(selector)
    self.at(selector).try(:text).to_s
  end
end

class PP
  class << self
    alias_method :old_pp, :pp
    def pp(obj, out = $>, width = 160)
      old_pp(obj, out, width)
    end
  end
end

class Hash
  def deep_stringify_keys!
    stringify_keys!
    values.select{ |v| Hash === v }.each(&:deep_stringify_keys!)
    values.select{ |v| Array === v }.each do |ary|
      ary.select{ |v| Hash === v }.each(&:deep_stringify_keys!)
    end
  end
end

class Set
  def ===(object)
    include?(object)
  end
end
