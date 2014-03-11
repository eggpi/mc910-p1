%{
#include <stdlib.h>
#include "parser.h"
%}

WHITESPACE [ \n\r\t]+

%option case-insensitive

%%

[[:space:]]+        /* ignore */ ;
"newspaper"         { return T_NEWSPAPER; }
"title"             { return T_TITLE; }
"date"              { return T_DATE; }
"abstract"          { return T_ABSTRACT; }
"text"              { return T_TEXT; }
"source"            { return T_SOURCE; }
"image"             { return T_IMAGE; }
"author"            { return T_AUTHOR; }
"structure"         { return T_STRUCTURE; }
"col"               { return T_COL; }
"show"              { return T_SHOW; }
"{"                 { return '{'; }
"}"                 { return '}'; }
","                 { return ','; }
";"                 { return ';'; }
"="                 { return '='; }

\/\/.*$ {
    // ignore comments
}

\".*\" {
    yylval.str = (char *) strdup(yytext);
    return T_LITERAL_STRING;
}

[a-z][a-zA-Z0-9_]* {
    yylval.str = (char *) strdup(yytext);
    return T_NEWSNAME;
}

[0-9]+ {
    yylval.num = strtoul(yytext, NULL, 10);
    return T_NUM;
}

. {
    fprintf(stderr, "Unexpected char %c (ASCII=%d).\n", yytext[0], yytext[0]);
}
