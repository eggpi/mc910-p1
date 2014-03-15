%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#include "parse_tree.h"

int yyerror(const char* errmsg);
int yylex(void);

char* concat(int count, ...);
%}

%union{
    char *str;
    unsigned long num;
    list_t *list;

    newspaper_t newspaper;
    structure_t structure;
    news_t news;
    text_field_t text;
}

%token <str> T_TEXT
%token T_NEWSPAPER
%token <str> T_TITLE
%token <str> T_DATE
%token <str> T_ABSTRACT
%token <str> T_SOURCE
%token <str> T_IMAGE
%token <str> T_AUTHOR
%token <str> T_STRUCTURE
%token T_COL
%token T_SHOW
%token <str> T_NEWSNAME
%token T_BOLD;
%token T_ITALICIZED;
%token T_TITLE_PARAGRAPH;
%token T_TEXT_LINK;
%token T_IMAGE_LINK;
%token T_PARAGRAPH;
%token <num> T_BULLET;
%token T_ENUMERATION;
%token <num> T_NUM
%token <str> T_QUOTED_CHAR

%type <num> col_stmt
%type <news> news_stmt news_attrs_stmt
%type <structure> structure_stmt news_structure_stmt
%type <newspaper> newspaper_stmt
%type <list> show_stmt news_show_stmt news_name_list news_attr_list news_list
%type <text> title_stmt abstract_stmt date_stmt author_stmt image_stmt text_stmt source_stmt quoted_string literal_string

%start newspaper_stmt

%error-verbose

%%

newspaper_stmt: T_NEWSPAPER '{'
    title_stmt
    date_stmt
    structure_stmt
    news_list
'}' {
    // FIXME it's probably wrong to take &$5,
    // here and everywhere else.
    $$.structure = &$5;
}
;

literal_string: '"' quoted_string '"' {
    $$ = $2;

    list_node_t *n;
    list_iterator_t *it = list_iterator_new($$.chunks, LIST_HEAD);

    while ((n = list_iterator_next(it))) {
        printf("%d %s\n", ((text_chunk_t *) n->val)->_pos, ((text_chunk_t *) n->val)->chunk);
    }
}
;

quoted_string:
    T_QUOTED_CHAR {
        /* FIXME: probably also need to initialize everything else
         here: $$.bold = false, etc. Use $$ = text_chunk_new() or so.
        */
        $$.chunks = list_new();
        text_field_append_char(&$$, $1[0]);
    }
    | quoted_string T_QUOTED_CHAR {
        text_field_append_char(&$$, $2[0]);
    }
    /* FIXME: also allow a string to _start_ with T_BOLD, T_ITALICIZED etc.
    The code should be similar to the one above:
        $$.chunks = list_new();
        $$.bold = true;
    */
    | quoted_string T_BOLD {
        $$.bold = !$$.bold;
    }
    | quoted_string T_ITALICIZED
    | quoted_string T_TITLE_PARAGRAPH
    | quoted_string T_TEXT_LINK
    | quoted_string T_IMAGE_LINK
    | quoted_string T_PARAGRAPH
    | quoted_string T_BULLET
    | quoted_string T_ENUMERATION
;

title_stmt: T_TITLE '=' literal_string {
    $$ = $3;
}
;

date_stmt: T_DATE '=' literal_string {
    $$ = $3;
}
;

structure_stmt: T_STRUCTURE '{'
    col_stmt
    show_stmt
'}' {
    $$.col = $3;
    $$.show = $4;
}
;

col_stmt: T_COL '=' T_NUM {
    $$ = yyval.num;
}
;

show_stmt: T_SHOW '=' news_name_list {
    $$ = $3;
}
;

news_name_list: T_NEWSNAME { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_name_list ',' T_NEWSNAME { list_rpush($$, list_node_new($3)); }
;

news_stmt: T_NEWSNAME '{'
    news_attrs_stmt
    news_structure_stmt
'}' {
    $$.structure = &$4;
    // the other attributes were filled out by news_attrs_stmt
}
;

news_list: news_stmt { $$ = list_new(); list_rpush($$, list_node_new(&$1)); }
    | news_list news_stmt { list_rpush($$, list_node_new(&$2)); }
;

news_attrs_stmt:
    title_stmt { $$.title = &$1; }
    | news_attrs_stmt title_stmt { $$.title = &$2; }
    | abstract_stmt { $$.abstract = &$1; }
    | news_attrs_stmt abstract_stmt { $$.abstract = &$2; }
    | author_stmt { $$.author = &$1; }
    | news_attrs_stmt author_stmt { $$.author = &$2; }
    | date_stmt { $$.date = &$1; }
    | news_attrs_stmt date_stmt { $$.date = &$2; }
    | image_stmt { $$.image = &$1; }
    | news_attrs_stmt image_stmt { $$.image = &$2; }
    | text_stmt { $$.text = &$1; }
    | news_attrs_stmt text_stmt { $$.text = &$2; }
    | source_stmt { $$.source = &$1; }
    | news_attrs_stmt source_stmt { $$.source = &$2; }
;

abstract_stmt: T_ABSTRACT '=' literal_string {
    $$ = $3;
}
;

author_stmt: T_AUTHOR '=' literal_string {
    $$ = $3;
}
;

image_stmt: T_IMAGE '=' literal_string {
    // FIXME this is wrong and causes a warning.
    // we probably want to parse the image path and caption
    // and insert it into the news here somehow
    $$ = $3;
}
;

text_stmt: T_TEXT '=' literal_string {
    $$ = $3;
}
;

source_stmt: T_SOURCE '=' literal_string {
    $$ = $3;
}
;

news_structure_stmt: T_STRUCTURE '{'
    col_stmt
    news_show_stmt
'}' {
    $$.col = $3;
    $$.show = $4;
}

news_show_stmt: T_SHOW '=' news_attr_list {
    $$ = $3;
}
;

news_attr_list:
    T_TITLE { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_TITLE { list_rpush($$, list_node_new($3)); }
    | T_ABSTRACT { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_ABSTRACT { list_rpush($$, list_node_new($3)); }
    | T_AUTHOR { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_AUTHOR { list_rpush($$, list_node_new($3)); }
    | T_DATE { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_DATE { list_rpush($$, list_node_new($3)); }
    | T_IMAGE { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_IMAGE { list_rpush($$, list_node_new($3)); }
    | T_TEXT { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_TEXT { list_rpush($$, list_node_new($3)); }
    | T_SOURCE { $$ = list_new(); list_rpush($$, list_node_new($1)); }
    | news_attr_list ',' T_SOURCE { list_rpush($$, list_node_new($3)); }
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
