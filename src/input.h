#ifndef INPUT_H
#define INPUT_H

#include <stddef.h>

char *jsh_read_line();
char **jsh_split_line(char *line);
int jsh_parse_and_execute(char *line);

char **allocate_tokens(size_t bufsize);
char **resize_tokens(char **tokens, size_t new_bufsize);
void free_tokens(char **tokens);

#endif
