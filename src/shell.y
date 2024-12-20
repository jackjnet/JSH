%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

int yylex (void);
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
%}

%token PIPE APPEND_OUTPUT REDIRECT_OUTPUT REDIRECT_INPUT BACKGROUND NEWLINE WORD NOTOKEN
%union {
    char *string;
    int number;
}

%%

command_list:
    command_list command NEWLINE { /* Process each command */ }
    |
    ;

command:
    command PIPE command { /* Handle pipeline */ }
    | WORD arguments { /* Handle command with arguments */ }
    ;

arguments:
    /* No arguments */
    | arguments WORD { /* Handle arguments */ }
    ;

%%

