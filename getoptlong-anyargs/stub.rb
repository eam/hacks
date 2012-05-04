#!/usr/bin/ruby

require 'getoptlong'

opts = GetoptLong.new()
opts.accept_all_args = GetoptLong::OPTIONAL_ARGUMENT
opts.return_nil_args = true

opts.each do |opt, arg|
  puts "SAW #{opt} and #{arg.inspect}"
end
