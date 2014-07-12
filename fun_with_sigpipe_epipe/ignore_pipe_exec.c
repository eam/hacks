#include <signal.h>
#include <unistd.h>
int main(int argc, char * argv[]) {
  signal(SIGPIPE, SIG_IGN);
  argv++;
  return execve(argv[0], argv, NULL);
}
