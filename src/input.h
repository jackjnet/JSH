#ifndef INPUT_H
#define INPUT_H

#include <stddef.h>

char *jsh_read_line();
char **jsh_split_line(char *line);
void free_tokens(char **tokens);

#endif
