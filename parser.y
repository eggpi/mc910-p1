%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

int yyerror(const char* errmsg);
int yylex(void);

char* concat(int count, ...);
%}

%union{
    char *str;
    unsigned long num;
}

%token T_TEXT
%token T_NEWSPAPER
%token T_TITLE
%token T_DATE
%token T_ABSTRACT
%token T_SOURCE
%token T_IMAGE
%token T_AUTHOR
%token T_STRUCTURE
%token T_COL
%token T_SHOW
%token T_NEWSNAME
%token <num> T_NUM
%token <str> T_QUOTED_STRING

%type <str> literal_string quoted_string_list

%start newspaper_stmt

%error-verbose

%%

newspaper_stmt: T_NEWSPAPER '{'
    title_stmt
    date_stmt
    structure_stmt
    news_list
'}'
;

literal_string: '"' quoted_string_list '"'
{ $$ = $2; }
;

quoted_string_list:
    T_QUOTED_STRING { $$ = $1; }
    | quoted_string_list T_QUOTED_STRING { $$ = concat(2, $1, $2); }
;

title_stmt: T_TITLE '=' literal_string
;

date_stmt: T_DATE '=' literal_string
;

structure_stmt: T_STRUCTURE '{'
    col_stmt
    show_stmt
'}'
;

col_stmt: T_COL '=' T_NUM
;

show_stmt: T_SHOW '=' news_name_list
;

news_name_list: news_name_list ',' T_NEWSNAME | T_NEWSNAME
;

news_stmt: T_NEWSNAME '{'
    news_attrs_stmt
    news_structure_stmt
'}'
;

news_list: news_list news_stmt | news_stmt
;

news_attrs_stmt:
    title_stmt
    | news_attrs_stmt title_stmt
    | abstract_stmt
    | news_attrs_stmt abstract_stmt
    | author_stmt
    | news_attrs_stmt author_stmt
    | date_stmt
    | news_attrs_stmt date_stmt
    | image_stmt
    | news_attrs_stmt image_stmt
    | text_stmt
    | news_attrs_stmt text_stmt
    | source_stmt
    | news_attrs_stmt source_stmt
;

abstract_stmt: T_ABSTRACT '=' literal_string
;

author_stmt: T_AUTHOR '=' literal_string
;

image_stmt: T_IMAGE '=' literal_string
;

text_stmt: T_TEXT '=' literal_string
;

source_stmt: T_SOURCE '=' literal_string
;

news_structure_stmt: T_STRUCTURE '{'
    col_stmt
    news_show_stmt
'}'

news_show_stmt: T_SHOW '=' news_attr_list
;

news_attr_list:
    T_TITLE
    | news_attr_list ',' T_TITLE
    | T_ABSTRACT
    | news_attr_list ',' T_ABSTRACT
    | T_AUTHOR
    | news_attr_list ',' T_AUTHOR
    | T_DATE
    | news_attr_list ',' T_DATE
    | T_IMAGE
    | news_attr_list ',' T_IMAGE
    | T_TEXT
    | news_attr_list ',' T_TEXT
    | T_SOURCE
    | news_attr_list ',' T_SOURCE
;

%%

char* concat(int count, ...)
{
    va_list ap;
    int len = 1, i;

    va_start(ap, count);
    for(i=0 ; i<count ; i++)
        len += strlen(va_arg(ap, char*));
    va_end(ap);

    char *result = (char*) calloc(sizeof(char),len);
    int pos = 0;

    // Actually concatenate strings
    va_start(ap, count);
    for(i=0 ; i<count ; i++)
    {
        char *s = va_arg(ap, char*);
        strcpy(result+pos, s);
        pos += strlen(s);
    }
    va_end(ap);

    return result;
}

int yyerror(const char* errmsg)
{
    fprintf(stderr, "\nError: %s\n", errmsg);
    return 0;
}

int yywrap(void) {
    return 1;
}

int main(int argc, char** argv)
{
    yyparse();
    return 0;
}
