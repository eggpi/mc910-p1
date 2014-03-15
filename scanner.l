%{
#include <stdlib.h>
#include "parse_tree.h"
#include "parser.h"

static int expect_markup;
%}

WHITESPACE [ \n\r\t]+

%option case-insensitive
%x LITERAL_STRING

%%

[[:space:]]+         /* ignore */ ;
"newspaper"          { return T_NEWSPAPER; }
"title"              { expect_markup = 1; yylval.str = (char *) strdup(yytext); return T_TITLE; }
"date"               { yylval.str = (char *) strdup(yytext); return T_DATE; }
"abstract"           { expect_markup = 1; yylval.str = (char *) strdup(yytext); return T_ABSTRACT; }
"text"               { expect_markup = 1; yylval.str = (char *) strdup(yytext); return T_TEXT; }
"source"             { yylval.str = (char *) strdup(yytext); return T_SOURCE; }
"image"              { yylval.str = (char *) strdup(yytext); return T_IMAGE; }
"author"             { yylval.str = (char *) strdup(yytext); return T_AUTHOR; }
"structure"          { return T_STRUCTURE; }
"col"                { return T_COL; }
"show"               { return T_SHOW; }
"{"                  { return '{'; }
"}"                  { return '}'; }
","                  { return ','; }
";"                  { return ';'; }
"="                  { return '='; }
"\""                 { BEGIN(LITERAL_STRING); return '"'; }

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
    return T_QUOTED_STR;
}

<LITERAL_STRING>\" {
    BEGIN(INITIAL);
    expect_markup = 0;
    return '"';
}

<LITERAL_STRING>\\\" {
    yylval.str = (char *) strdup(yytext);
    return T_QUOTED_STR;
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

<LITERAL_STRING>\[[^|]+(\|[^\]]+)?\] {
    yylval.str = (char *) strdup(yytext);
    return expect_markup ? T_TEXT_LINK : T_QUOTED_STR;
}

<LITERAL_STRING>\[\[[^|]+\|[^\]]+\]\] {
    yylval.str = (char *) strdup(yytext);
    return expect_markup ? T_IMAGE_LINK : T_QUOTED_STR;
}

<LITERAL_STRING>:+ {
    if (expect_markup) {
        yylval.num = strlen(yytext);
        return T_PARAGRAPH;
    } else {
        yylval.str = (char *) strdup(yytext);
        return T_QUOTED_STR;
    }
}

<LITERAL_STRING>\*+ {
    if (expect_markup) {
        yylval.num = strlen(yytext);
        return T_BULLET;
    } else {
        yylval.str = (char *) strdup(yytext);
        return T_QUOTED_STR;
    }
}

<LITERAL_STRING>#+ {
    if (expect_markup) {
        yylval.num = strlen(yytext);
        return T_ENUMERATION;
    } else {
        yylval.str = (char *) strdup(yytext);
        return T_QUOTED_STR;
    }
}

. {
    fprintf(stderr, "Unexpected char %c (ASCII=%d).\n", yytext[0], yytext[0]);
}
