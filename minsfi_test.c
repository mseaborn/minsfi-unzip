
#include <unistd.h>

void func1(void) {
  static const char str[] = "In address-taken function\n";
  write(1, str, sizeof(str) - 1);
}

void func2(int fd) {
  static const char str[] = "In second address-taken function\n";
  write(fd, str, sizeof(str) - 1);
}

void (*func1_ptr)(void) = func1;
void (*func2_ptr)(int fd) = func2;

int main() {
  static const char str[] = "Hello, world!\n";
  write(1, str, sizeof(str) - 1);

  func1_ptr();
  func2_ptr(1);
  func2(1);

  return 0;
}
