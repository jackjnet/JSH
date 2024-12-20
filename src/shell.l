%{
#include <string.h>
#include "y.tab.h"
%}

%%

">>"[ \t]*[^ \t\n]+ { yylval.string = strdup(yytext + 2); return APPEND_OUTPUT; }
">"[ \t]*[^ \t\n]+   { yylval.string = strdup(yytext + 1); return REDIRECT_OUTPUT; }
"<"[ \t]*[^ \t\n]+   { yylval.string = strdup(yytext + 1); return REDIRECT_INPUT; }

"|"         { return PIPE; }
"&"         { return BACKGROUND; }

\"([^\"\\]|\\.)*\" { 
    yylval.string = strdup(yytext + 1); 
    yylval.string[strlen(yylval.string) - 1] = '\0'; 
    return WORD; }
\'[^\']*\' { 
    yylval.string = strdup(yytext + 1); 
    yylval.string[strlen(yylval.string) - 1] = '\0'; 
    return WORD; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.string = strdup(yytext); return WORD; }


[ \t]+      { /* Ignore whitespace */ }
\n          { return NEWLINE; }

#.*         { /* Ignore comments   */ }
.           { return NOTOKEN; }

%%

int yywrap() {
    return 1; /* Indicate end of input */
}
