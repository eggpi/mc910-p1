%{
#include <stdio.h>
#include <stdlib.h>

int yyerror(const char* errmsg);
int yylex(void);
%}
 
%union{
    char *str;
    unsigned long num;
}

%token <str> T_TEXT
%token <str> T_LITERAL_STRING
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

title_stmt: T_TITLE '=' T_LITERAL_STRING
;

date_stmt: T_DATE '=' T_LITERAL_STRING
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

abstract_stmt: T_ABSTRACT '=' T_LITERAL_STRING
;

author_stmt: T_AUTHOR '=' T_LITERAL_STRING
;

image_stmt: T_IMAGE '=' T_LITERAL_STRING
;

text_stmt: T_TEXT '=' T_LITERAL_STRING
;

source_stmt: T_SOURCE '=' T_LITERAL_STRING
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
;

%%
 
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
