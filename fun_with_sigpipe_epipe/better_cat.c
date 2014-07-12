#include <unistd.h>
#define BUFFSZ 4096

int main() {
  char b[BUFFSZ];
  int len = 0;
  while (1) {
    len = read(0, b, BUFFSZ);
    if (len < 1) { break; }   // empty read means EOF
    write(1, b, len);
  }
  return 0;
}
