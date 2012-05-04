#!/usr/bin/ruby

require 'getoptlong'

opts = GetoptLong.new()
opts.accept_all_args = GetoptLong::REQUIRED_ARGUMENT

opts.each do |opt, arg|
  puts "SAW #{opt} and #{arg}"
end
