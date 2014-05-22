
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>


unsigned __sfi_stack = 0x40000000;


static uintptr_t next_alloc = 0x10000000;

void *malloc(size_t size) {
  uintptr_t addr = next_alloc;
  next_alloc += size;
  int align_mask = 7;
  next_alloc = (next_alloc + align_mask) & ~align_mask;
  return (void *) addr;
}

void free(void *block) {
}

void *realloc(void *block, size_t size) {
  return malloc(size);
}

void *calloc(size_t nmemb, size_t size) {
  return malloc(nmemb * size);
}


struct _reent;

void *_malloc_r(struct _reent *ptr, size_t size) {
  return malloc(size);
}

void _free_r(struct _reent *ptr, void *addr) {
  free(addr);
}

void *_realloc_r(struct _reent *ptr, void *block, size_t size) {
  return realloc(block, size);
}

void *_calloc_r(struct _reent *ptr, size_t size, size_t len) {
  return calloc(size, len);
}


int open(char const *pathname, int oflag, ...) {
  __builtin_trap();
}

int fstat(int fd, struct stat *st) {
  __builtin_trap();
}

int isatty(int fd) {
  __builtin_trap();
}

off_t lseek(int fd, off_t offset, int whence) {
  __builtin_trap();
}

int close(int fd) {
  __builtin_trap();
}

int write(int fd, const void *buf, size_t count) {
  __builtin_trap();
}

int read(int fd, void *buf, size_t count) {
  __builtin_trap();
}

void _exit(int status) {
  __builtin_trap();
}

int mkdir(const char *path, mode_t mode) {
  __builtin_trap();
}

int chdir(const char *path) {
  __builtin_trap();
}

int utime(const char *filename, const struct utimbuf *buf) {
  __builtin_trap();
}
