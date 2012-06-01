#!/usr/bin/ruby

require 'pp'

system "rm -f rubymain.o	syspoll.bundle Makefile"
system "./extconf.rb"
system "make"

require "syspoll"
include SysPoll


# need to make PollFd.new() be method_make_pollfd_struct()
# and add functions to access the internal data
poll_struct = PollFd.new(0,7)
#poll_struct = make_pollfd_struct(0, 8)
poll_struct.get_revents

pp poll_struct
# poll() timeout is in ms, so 1_000 is one second
poll([
    #  [1,8],
      poll_struct,
     ], 1000 )


puts "I saw revents of: #{poll_struct.get_revents}"
