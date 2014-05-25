
#include <unistd.h>

static const char str[] = "Hello, world!\n";

int main() {
  write(1, str, sizeof(str) - 1);
  return 0;
}
