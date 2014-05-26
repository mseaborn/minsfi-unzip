
#include <unistd.h>

void func1(void) {
  static const char str[] = "In address-taken function\n";
  write(1, str, sizeof(str) - 1);
}

void (*func1_ptr)(void) = func1;

int main() {
  static const char str[] = "Hello, world!\n";
  write(1, str, sizeof(str) - 1);

  func1_ptr();

  return 0;
}
