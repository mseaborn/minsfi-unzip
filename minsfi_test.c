
#include <stdio.h>
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

int main(int argc, char **argv) {
  static const char str[] = "Hello, world!\n";
  write(1, str, sizeof(str) - 1);

  func1_ptr();
  func2_ptr(1);
  func2(1);

  fprintf(stderr, "Hello world to stderr, via printf()\n");
  printf("Hello world to stdout, via printf()\n");

  printf("argc = %i\n", argc);
  int i;
  for (i = 0; i < argc; i++) {
    printf("argv[%i] = \"%s\"\n", i, argv[i]);
  }

  return 0;
}
