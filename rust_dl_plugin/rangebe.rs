// we want a .so file
#![crate_type = "dylib"]

extern crate libc;
use libc::c_char;
use std::str;

// no_mangle lets us find the name in the symbol table
// extern makes the function externally visible
#[no_mangle]
pub extern fn square(x: i32) -> i32 {
    x * x
}

#[no_mangle]
pub extern fn hello() -> *const c_char {
    return "hello world\n".as_ptr() as *const i8
}

/*

#[no_mangle]
pub extern fn hello_worlds() -> *const *const c_char {
}


fn vec_return() -> Vec<*const c_char> {
  return vec![("hello world\n".as_ptr() as *const i8)]
}

*/
