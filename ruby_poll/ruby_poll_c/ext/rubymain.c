#include <ruby.h>
#include <stdio.h>
#include <poll.h>

VALUE cSysPoll = Qnil;
VALUE cSysPoll_PollFd = Qnil;

VALUE method_poll(VALUE self, VALUE pollfd_array, VALUE timeout) {
  printf("hello from method_poll()\n");
  Check_Type(pollfd_array, T_ARRAY);
  Check_Type(timeout, T_FIXNUM);
  long int pollfd_array_len = RARRAY(pollfd_array)->len;
  printf("got array with %ld length\n", pollfd_array_len);
  printf("got timeout of %d\n", NUM2INT(timeout));

  /* transform array of ruby stuff into struct pollfd fds[] */

  // get memory for c struct
  struct pollfd *fds = ALLOCA_N(struct pollfd, pollfd_array_len);

  // walk each array
  int i = 0;
  for (i = 0; i < pollfd_array_len; i++) {
    struct pollfd *p;
    // for now, each array entry is another array of 3 fixnums
    // TODO, make a struct of fd/uint/uint and export poll bitfields
    VALUE entry = rb_ary_entry(pollfd_array, i);
    entry = rb_iv_get(entry, "@pollfd_struct");
    /*    Check_Type(entry, T_ARRAY);
    if (RARRAY(entry)->len != 2) {
      rb_raise(rb_eException, "bad pollfd_array values" );
    }
    */
    printf("processing a fd entry\n");
    printf("SEEN: %d\n", TYPE(entry));
    Data_Get_Struct(entry, struct pollfd, p);
    printf("INDEX: %d SAW-fd: %d SAW-events: %d\n", i, p->fd, p->events);
    
    fds[i].fd      = p->fd;
    fds[i].events  = p->events;
    fds[i].revents = 0;
  }
  int ret = poll(fds, pollfd_array_len, NUM2INT(timeout));
  printf("poll returned %d and revents 0/1 are %d / %d \n", ret, fds[0].revents, fds[1].revents);
  // Now convert back -- only revents changes
  for (i = 0; i < pollfd_array_len; i++) {
    struct pollfd *p;
    VALUE entry = rb_ary_entry(pollfd_array, i); // get instance of PollFd
    entry = rb_iv_get(entry, "@pollfd_struct"); //  Get PollFd.@pollfd_struct
    Data_Get_Struct(entry, struct pollfd, p);
    p->revents = fds[i].revents;
  }
  
  return INT2NUM(ret);
}


VALUE method_make_pollfd_struct(VALUE self, VALUE fd, VALUE events) {
  struct pollfd *p;
  VALUE retval;
  p = ALLOC(struct pollfd);
  p->fd      = NUM2INT(fd);
  p->events  = NUM2INT(events);
  p->revents = 0;
  retval = Data_Wrap_Struct(cSysPoll_PollFd, NULL, free, p);
  rb_iv_set(self, "@pollfd_struct", retval);
  return self;
}

VALUE method_get_revents(VALUE self) {
  struct pollfd *p;
  VALUE rb_t;
  rb_t = rb_iv_get(self, "@pollfd_struct");
  Data_Get_Struct(rb_t, struct pollfd, p);
  return INT2NUM(p->revents);
}

void Init_syspoll() {
  printf("hello world from Init_syspoll()\n");
  cSysPoll = rb_define_module("SysPoll"); // Module SysPoll
  cSysPoll_PollFd = rb_define_class("PollFd", rb_cObject); // class SysPoll::PollFd
  rb_define_method(cSysPoll, "poll", method_poll, 2);
  rb_define_method(cSysPoll_PollFd, "initialize", method_make_pollfd_struct, 2);
  rb_define_method(cSysPoll_PollFd, "get_revents", method_get_revents, 0);
}

