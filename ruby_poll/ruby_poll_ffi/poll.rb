#!/usr/bin/ruby


class IO
  module Poll
    arch, os = RUBY_PLATFORM.split('-')
    if os =~ /^darwin/
      # /usr/include/sys/poll.h
      # Requestable events.  If poll(2) finds any of these set, they are
      # copied to revents on return.
      POLLIN         = 0x0001          #/* any readable data available */
      POLLPRI        = 0x0002          #/* OOB/Urgent readable data */
      POLLOUT        = 0x0004          #/* file descriptor is writeable */
      POLLRDNORM     = 0x0040          #/* non-OOB/URG data available */
      POLLWRNORM     = POLLOUT         #/* no write type differentiation */
      POLLRDBAND     = 0x0080          #/* OOB/Urgent readable data */
      POLLWRBAND     = 0x0100          #/* OOB/Urgent data can be written */
      # FreeBSD extensions: polling on a regular file might return one
      # of these events (currently only supported on local filesystems).
      POLLEXTEND     = 0x0200          #/* file may have been extended */
      POLLATTRIB     = 0x0400          #/* file attributes may have changed */
      POLLNLINK      = 0x0800          #/* (un)link/rename may have happened */
      POLLWRITE      = 0x1000          #/* file's contents may have changed */
      # These events are set if they occur regardless of whether they were
      # requested
      POLLERR        = 0x0008          #/* some poll error occurred */
      POLLHUP        = 0x0010          #/* file descriptor was "hung up" */
      POLLNVAL       = 0x0020          #/* requested events "invalid" */
      
      POLLSTANDARD   = (POLLIN|POLLPRI|POLLOUT|POLLRDNORM|POLLRDBAND|POLLWRBAND|POLLERR|POLLHUP|POLLNVAL)
      
    elsif os == "linux"
      # /usr/include/bits/poll.h
      #/* Event types that can be polled for.  These bits may be set in `events'
      # to indicate the interesting event types; they will appear in `revents'
      # to indicate the status of the file descriptor.  */
      POLLIN         = 0x001           #/* There is data to read.  */
      POLLPRI        = 0x002           #/* There is urgent data to read.  */
      POLLOUT        = 0x004           #/* Writing now will not block.  */
      
      #/* These values are defined in XPG4.2.  */
      POLLRDNORM    = 0x040           #/* Normal data may be read.  */
      POLLRDBAND    = 0x080           #/* Priority data may be read.  */
      POLLWRNORM    = 0x100           #/* Writing now will not block.  */
      POLLWRBAND    = 0x200           #/* Priority data may be written.  */
      
      #/* These are extensions for Linux.  */
      POLLMSG       = 0x400
      POLLREMOVE    = 0x1000
      POLLRDHUP     = 0x2000
      
      #/* Event types always implicitly polled for.  These bits need not be set in
      #   `events', but they will appear in `revents' to indicate the status of
      #   the file descriptor.  */
      POLLERR        = 0x008          # /* Error condition.  */
      POLLHUP        = 0x010          # /* Hung up.  */
      POLLNVAL       = 0x020          # /* Invalid polling request.  */
      
      # not part of poll.h on linux, but looks handy
      POLLSTANDARD   = (POLLIN|POLLPRI|POLLOUT|POLLRDNORM|POLLRDBAND|POLLWRBAND|POLLERR|POLLHUP|POLLNVAL)
      
    else
      raise "unknown platform: #{RUBY_PLATFORM}"
    end
  end # module IO::Poll
end # class IO

# poll() constants



# s_     | Integer | signed short, native endian
# i, i_  | Integer | signed int, native endian
# syscall SYS_poll, [STDIN.fileno, ]

require 'rubygems'
require 'ffi'

class IO
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  class PollFdStruct < FFI::Struct
    layout :fd, :int,
    :events, :short,
    :revents, :short
  end

  attach_function 'poll', [:pointer, :int, :int], :int

  def IO.select_using_poll(read, write, error, timeout)
    all = read.map { |f| { :io => f, :events => IO::Poll::POLLIN } } +
          write.map { |f| { :io => f, :events => IO::Poll::POLLOUT } } +
          error.map { |f| { :io => f, :events => IO::Poll::POLLERR } }
    pollfds = FFI::MemoryPointer.new(IO::PollFdStruct, all.length)
    all.each_with_index do |poll, i|
      struct = IO::PollFdStruct.new(pollfds[i])
      struct[:fd] = poll[:io].fileno
      struct[:events] = poll[:events]
      struct[:revents] = 0
    end
    ret = IO.poll(pollfds, all.length, timeout)
    if ret < 0
      # error. FIXME replace this with the appropriate exceptions FIXME
      raise "poll error"
    elsif 0 == ret
      # timed out, exit fast
      return [[][][]]
    else
      # returned some interesting descriptors
      ret_read, ret_write, ret_error = [], [], []
      all.each_with_index do |poll, i|
        # select() will signal unrequested flags (eg POLLNVAL) which must be passed
        # back to the correct read/write/error fdset. So, test what we were requesting,
        # and return the fd if *any* notification occured, even if it wasn't what we asked for
        struct = IO::PollFdStruct.new(pollfds[i])
        next if 0 == struct[:revents]
        ret_read << poll[:io] if poll[:events] == IO::Poll::POLLIN and not struct[:revents].zero?
        ret_write << poll[:io] if poll[:events] == IO::Poll::POLLOUT and not struct[:revents].zero?
        ret_error << poll[:io] if poll[:events] == IO::Poll::POLLERR and not struct[:revents].zero?
        STDERR.puts "revents for #{poll[:io].inspect} are: #{struct[:revents]}"
      end
      return [ret_read, ret_write, ret_error]
    end # if/else ret
  end # select_using_poll()

end # class IO

Struct.new("PollFdStruct", :fd, :events, :revents)

pollfd_len = 3
pollfds = FFI::MemoryPointer.new(IO::PollFdStruct, pollfd_len)

#  pollfds_rb = []
#  x = PollFdStruct.new
#STDERR.puts "pointer is: #{pollfds.get_pointer(0)}"
pollfd_len.times do |i|
  struct = IO::PollFdStruct.new(pollfds[i])
  struct[:fd] = i
  struct[:events] = 7
  struct[:revents] = 0
end

#  pollfds_rb.each_with_index do |p, i|
#    struct_bytes = pollfds_rb[i].get_bytes(0, PollFdStruct.size)
#    pollfds[i].put_bytes(0, struct_bytes)
#  end

ret = IO.poll(pollfds, pollfd_len, 4);

STDERR.puts "ret: #{ret.inspect}"

x = IO.select_using_poll([STDIN], [STDOUT], [], 5);

STDERR.puts "IO.select_using_poll([#{STDIN.inspect}], [#{STDOUT.inspect}], [], 5):"
STDERR.puts x.inspect
STDERR.puts "and inval is: #{IO::Poll::POLLNVAL}"
