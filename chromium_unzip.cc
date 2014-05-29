
#include <stdio.h>

#include "third_party/zlib/google/zip.h"

int main(int argc, char **argv) {
  if (argc != 3) {
    fprintf(stderr, "Usage: %s <zip-file> <dest-dir>\n", argv[0]);
    return 1;
  }
  base::FilePath zip_file(argv[1]);
  base::FilePath dest_dir(argv[2]);
  return zip::Unzip(zip_file, dest_dir) ? 0 : 1;
}
