
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <unistd.h>


unsigned __sfi_stack = 0x40000000;


/* Copied from pnacl/support/bitcode/crti.c */
void _init(void) {
}


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


struct utimbuf;

int sandboxed_open(const char *pathname, int flags, int mode);
int sandboxed_chdir(const char *pathname);

int sandboxed_close(int fd);
off_t sandboxed_lseek(int fd, off_t offset, int whence);
int sandboxed_read(int fd, void *buf, size_t count);
int sandboxed_write(int fd, const void *buf, size_t count);

int open(const char *pathname, int flags, ...) {
  mode_t mode = 0;
  if (flags & O_CREAT) {
    va_list ap;
    va_start(ap, flags);
    mode = va_arg(ap, mode_t);
    va_end(ap);
  }
  return sandboxed_open(pathname, flags, mode);
}

int close(int fd) {
  return sandboxed_close(fd);
}

int fstat(int fd, struct stat *st) {
  errno = ENOSYS;
  return -1;
}

int isatty(int fd) {
  __builtin_trap();
}

off_t lseek(int fd, off_t offset, int whence) {
  return sandboxed_lseek(fd, offset, whence);
}

int read(int fd, void *buf, size_t count) {
  return sandboxed_read(fd, buf, count);
}

int write(int fd, const void *buf, size_t count) {
  return sandboxed_write(fd, buf, count);
}

void _exit(int status) {
  __builtin_trap();
}

int mkdir(const char *path, mode_t mode) {
  __builtin_trap();
}

int chdir(const char *path) {
  return sandboxed_chdir(path);
}

int utime(const char *filename, const struct utimbuf *buf) {
  errno = ENOSYS;
  return -1;
}


/* libnacl does not include this: */

long pathconf(const char *path, int name) {
  errno = ENOSYS;
  return -1;
}


int main(int argc, char **argv);

void __newlib_thread_init(void);
void __libc_init_array(void);

int _start(int argc, char **argv) {
  __newlib_thread_init();
  __libc_init_array();

  return main(argc, argv);
}
