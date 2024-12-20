#include "executor.h"
#include <readline/history.h>
#include <readline/readline.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

#define TOKEN_DELIMITERS " \t\r\n\a"
#define STARTING_SIZE 16

char **allocate_tokens(size_t bufsize) {
  char **tokens = (char **)malloc(bufsize * sizeof(char *));
  if (!tokens) {
    perror("malloc failure");
    exit(EXIT_FAILURE);
  }
  return tokens;
}

char **resize_tokens(char **tokens, size_t new_bufsize) {
  void *temp = realloc(*tokens, new_bufsize * sizeof(char *));
  if (!temp) {
    free((void *)tokens);
    perror("realloc failure");
    exit(EXIT_FAILURE);
  }
  return (char **)temp;
}

void free_tokens(char **tokens) {
  if (tokens) {
    for (size_t i = 0; tokens[i] != NULL; i++) {
      free(tokens[i]);
    }
    free((void *)tokens);
  }
}

char *jsh_read_line() {
  char *line = readline("jsh>");

  if (line && *line && strspn(line, TOKEN_DELIMITERS) != strlen(line)) {
    add_history(line);
  }

  return line;
}

char **jsh_split_line(char *line) {
  if (line == NULL) {
    return NULL;
  }

  size_t bufsize = STARTING_SIZE;
  char **tokens = allocate_tokens(bufsize);
  if (!tokens) {
    perror("malloc failure");
    exit(EXIT_FAILURE);
  }

  size_t position = 0;
  char *token = strtok(line, TOKEN_DELIMITERS);

  while (token != NULL) {
    tokens[position] = strdup(token);
    if (!tokens[position]) {
      free_tokens(tokens);
      perror("strdup failure");
      exit(EXIT_FAILURE);
    }
    position++;

    if (position >= bufsize) {
      bufsize *= 2;
      tokens = resize_tokens(tokens, bufsize);
    }

    token = strtok(NULL, TOKEN_DELIMITERS);
  }

  tokens[position] = NULL;
  return tokens;
}

#ifdef DEBUG
// Debugging function to print tokens
void print_tokens(char **tokens) {
  if (tokens) {
    for (int i = 0; tokens[i] != NULL; i++) {
      printf("Token[%d]: %s\n", i, tokens[i]);
    }
  }
}
#endif
