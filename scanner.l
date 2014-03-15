%{
#include <stdlib.h>
#include "parse_tree.h"
#include "parser.h"
%}

WHITESPACE [ \n\r\t]+

%option case-insensitive
%x LITERAL_STRING

%%

[[:space:]]+        /* ignore */ ;
"newspaper"         { return T_NEWSPAPER; }
"title"             { yylval.str = (char *) strdup(yytext); return T_TITLE; }
"date"              { yylval.str = (char *) strdup(yytext); return T_DATE; }
"abstract"          { yylval.str = (char *) strdup(yytext); return T_ABSTRACT; }
"text"              { yylval.str = (char *) strdup(yytext); return T_TEXT; }
"source"            { yylval.str = (char *) strdup(yytext); return T_SOURCE; }
"image"             { yylval.str = (char *) strdup(yytext); return T_IMAGE; }
"author"            { yylval.str = (char *) strdup(yytext); return T_AUTHOR; }
"structure"         { return T_STRUCTURE; }
"col"               { return T_COL; }
"show"              { return T_SHOW; }
"{"                 { return '{'; }
"}"                 { return '}'; }
","                 { return ','; }
";"                 { return ';'; }
"="                 { return '='; }
"\""                { BEGIN(LITERAL_STRING); return '"'; }

\/\/.*$ {
    // ignore comments
}

[a-z][a-zA-Z0-9_]* {
    yylval.str = (char *) strdup(yytext);
    return T_NEWSNAME;
}

[0-9]+ {
    yylval.num = strtoul(yytext, NULL, 10);
    return T_NUM;
}

<LITERAL_STRING>[^\\":*#] {
    yylval.str = (char *) strdup(yytext);
    return T_QUOTED_CHAR;
}

<LITERAL_STRING>\" {
    BEGIN(INITIAL);
    return '"';
}

<LITERAL_STRING>\\\" {
    yylval.str = (char *) strdup(yytext);
    return T_QUOTED_CHAR;
}

<LITERAL_STRING>''' {
    return T_BOLD;
}

<LITERAL_STRING>'' {
    return T_ITALICIZED;
}

<LITERAL_STRING>=== {
    return T_TITLE_PARAGRAPH;
}

<LITERAL_STRING>\[[^|]+\|[^\]]+\] {
    return T_TEXT_LINK;
}

<LITERAL_STRING>\[\[[^|]+\|[^\]]+\]\] {
    return T_IMAGE_LINK;
}

<LITERAL_STRING>: {
    return T_PARAGRAPH;
}

<LITERAL_STRING>\*+ {
    yylval.num = strlen(yytext);
    return T_BULLET;
}

<LITERAL_STRING>#+ {
    return T_ENUMERATION;
}

. {
    fprintf(stderr, "Unexpected char %c (ASCII=%d).\n", yytext[0], yytext[0]);
}
