#include "executor.h"
#include "input.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void jsh_loop(void) {
  char *line;
  char **args;
  int status;

  do {
    line = jsh_read_line();
    if (!line) {
      printf("\n");
      break;
    }

    args = jsh_split_line(line);
    status = jsh_launch(args);

    free(line);
    free_tokens(args);
  } while (status);
}

int main(int argc, char **argv) {
  // Load config files

  // Run command loop
  jsh_loop();

  // Shutdown/cleanup
}
